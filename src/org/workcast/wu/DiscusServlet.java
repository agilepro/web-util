package org.workcast.wu;

import javax.servlet.ServletContext;

import com.purplehillsbooks.web.JSONHandler;
import com.purplehillsbooks.web.JSONServlet;
import com.purplehillsbooks.web.SessionManager;
import com.purplehillsbooks.web.WebRequest;

public class DiscusServlet extends JSONServlet {

    private static final long serialVersionUID = 1007L;

    @Override
    public JSONHandler constructHandler(WebRequest wr) throws Exception {
        return new DiscusHandler(wr, smgr);
    }

    @Override
    public SessionManager constructSessionManager(ServletContext sc)
            throws Exception {
        return SessionManager.getSessionManagerSingleton(sc);
    }

}
