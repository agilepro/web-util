package org.workcast.wu;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.purplehillsbooks.xml.Mel;

public class XMLScrub {
    
    public List<String> errors = new ArrayList<String>();
    public Map<String,String> urlToNamespace = new HashMap<String,String>();
    public Map<String,String> namespaceToUrl = new HashMap<String,String>();
    public StringCounter nsUrlCount = new StringCounter();
    public Map<String,String> idToPath = new HashMap<String,String>();
    public Map<String,String> refToPath = new HashMap<String,String>();
    public StringCounter refCount = new StringCounter();
    
    public XMLScrub() {
        //nothing yet
    }
    
    public List<String> getErrors() {
        return errors;
    }
    
    
    public Map<String, Integer> collectAllNamespaceCounts(Mel root) throws Exception {
        
        recursiveNamespace(root);
        return nsUrlCount.guts;
        
    }
    
    private void recursiveNamespace(Mel element) throws Exception {
        
        //first, check the attributes of this node
        for (String attName : element.getAllAttributeNames()) {
            if (attName.startsWith("xmlns")) {
                String url = element.getAttribute(attName);
                String nsUrl = attName+"|"+url;
                nsUrlCount.increment(nsUrl);
            }
        }
        
        for (Mel child : element.getAllChildren()) {
            recursiveNamespace(child);
        }
    }
    
    public int countPrefixUse(Mel element, String prefix) throws Exception {
        return recursivePrefixCount(element, prefix);
    }
    
    private int recursivePrefixCount(Mel element, String prefix) throws Exception {
        int count = 0;
        
        String name = element.getPrefix();
        if (name.equals(prefix)) {
            count++;
        }
        //first, check the attributes of this node
        for (String attName : element.getAllAttributeNames()) {
            int colonPos = attName.indexOf(':');
            if (colonPos>0) {
                String ns = attName.substring(0,colonPos);
                if (ns.equals(prefix)) {
                    count++;
                }
            }
        }
        
        for (Mel child : element.getAllChildren()) {
            count = count + recursivePrefixCount(child, prefix);
        }
        return count;
    }
    
    public void calculateIdRefCounts(Mel root) throws Exception {
        
        recursiveIdSearch(root, "", 0);
    }
    
    public void recursiveIdSearch(Mel element, String path, int index) throws Exception {
        String newPath = path + " / " + element.getName();
        if (index>0) {
            newPath = newPath + "[" + index + "]";
        }
        StringCounter eNum = new StringCounter();
        StringCounter total = new StringCounter();
        
        String id = element.getAttribute("id");
        if (id != null) {
            if (id.length()==0) {
                id = "MISSING";
            }
            idToPath.put(id, newPath);
        }

        String ref = element.getAttribute("dmnElementRef");
        if (ref!=null) {
            if (ref.length()==0) {
                ref = "MISSING";
            }
            refToPath.put(ref, newPath);
            refCount.increment(ref);
        }
        
        for (Mel child : element.getAllChildren()) {
            total.increment(child.getName());
        }
        for (Mel child : element.getAllChildren()) {
            int newIndex = eNum.increment(child.getName());
            if (total.getCount(child.getName())==1) {
                //suppress the bracket when there is only one
                newIndex = 0;
            }
            recursiveIdSearch(child, newPath, newIndex);
        }
    }
}
