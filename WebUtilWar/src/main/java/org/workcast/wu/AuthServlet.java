package org.workcast.wu;


import com.purplehillsbooks.web.JSONHandler;
import com.purplehillsbooks.web.JSONServlet;
import com.purplehillsbooks.web.SessionManager;
import com.purplehillsbooks.web.WebRequest;

import jakarta.servlet.ServletContext;

public class AuthServlet extends JSONServlet {

    private static final long serialVersionUID = 1007L;

    @Override
    public JSONHandler constructHandler(WebRequest wr) throws Exception {
        return new AuthHandler(wr, smgr);
    }

    @Override
    public SessionManager constructSessionManager(ServletContext sc)
            throws Exception {
        return SessionManager.getSessionManagerSingleton(sc);
    }

}
