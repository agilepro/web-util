package org.workcast.wu;

public class Point {
        
    double dx;
    double dy;
    double dz;

    
    public float getX() {
        return (float) dx;
    }
    public void setX(float newX) {
        dx = (double) newX;
    }
    
    public float getY() {
        return (float) dy;
    }
    public void setY(float newY) {
        dy = (double) newY;
    }
    
    public float getZ() {
        return (float) dz;
    }
    public void setZ(float newZ) {
        dz = (double) newZ;
    }
}


class foo {
    
    public float getVolume(Point p) {
        
        return p.getX() * p.getY() * p.getZ();
        
    }
}