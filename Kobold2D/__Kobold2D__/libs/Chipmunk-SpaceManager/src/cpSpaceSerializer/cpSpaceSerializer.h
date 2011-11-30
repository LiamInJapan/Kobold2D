//
//  cpSpaceSerializer.h
//
//  Created by Robert Blackwood on 4/8/10.
//  Copyright 2010 Mobile Bros. All rights reserved.
//


#include "tinyxml/tinyxml.h"

//extern "C" {
#include "chipmunk.h"
//}

#include <map>

#define CPSS_DEFAULT_MAKE_ID(ptr) (reinterpret_cast<long>(ptr))

class cpSpaceSerializerDelegate
{
public:
	virtual long makeId(cpShape* shape) {return CPSS_DEFAULT_MAKE_ID(shape);}
	virtual long makeId(cpBody* body) {return CPSS_DEFAULT_MAKE_ID(body);}
	virtual long makeId(cpConstraint* constraint) {return CPSS_DEFAULT_MAKE_ID(constraint);}
	
	virtual bool writing(cpShape *shape, long shapeId) {return true;}
	virtual bool writing(cpBody *body, long bodyId) {return true;}
	virtual bool writing(cpConstraint *constraint, long constraintId) {return true;}
	
	virtual bool reading(cpShape *shape, long shapeId) {return true;}
	virtual bool reading(cpBody *body, long bodyId) {return true;}
	virtual bool reading(cpConstraint *constraint, long constraintId) {return true;}
};

class cpSpaceSerializer 
{
public:
	cpSpaceSerializer() : delegate(NULL) {}
	cpSpaceSerializer(cpSpaceSerializerDelegate *delegate) : delegate(delegate) {}
	
	cpSpace* load(const char* filename);
	cpSpace* load(cpSpace *space, const char* filename);
	bool save(cpSpace* space, const char* filename);
	
	cpSpaceSerializerDelegate *delegate;
		
	//Reading
	virtual cpShape *createShape(TiXmlElement *elm);
	cpShape *createCircle(TiXmlElement *elm);
	cpShape *createSegment(TiXmlElement *elm);
	cpShape *createPoly(TiXmlElement *elm);
	
	cpBody *createBody(TiXmlElement *elm);
	
	void createBodies(TiXmlElement *elm, cpBody **a, cpBody **b);
	virtual cpConstraint *createConstraint(TiXmlElement *elm);
	cpConstraint *createPinJoint(TiXmlElement *elm);
	cpConstraint *createSlideJoint(TiXmlElement *elm);
	cpConstraint *createPivotJoint(TiXmlElement *elm);
	cpConstraint *createGrooveJoint(TiXmlElement *elm);
	cpConstraint *createMotorJoint(TiXmlElement *elm);
	cpConstraint *createGearJoint(TiXmlElement *elm);
	cpConstraint *createSpringJoint(TiXmlElement *elm);
	cpConstraint *createRotaryLimitJoint(TiXmlElement *elm);
	cpConstraint *createRatchetJoint(TiXmlElement *elm);
	cpConstraint *createRotarySpringJoint(TiXmlElement *elm);
	
	cpVect createPoint(const char* name, TiXmlElement *elm);
	
	//Writing
	virtual TiXmlElement *createShapeElm(cpShape *shape);
	TiXmlElement *createCircleElm(cpShape *shape);
	TiXmlElement *createSegmentElm(cpShape *shape);
	TiXmlElement *createPolyElm(cpShape *shape);

	TiXmlElement *createBodyElm(cpBody *body);
	
	virtual TiXmlElement *createConstraintElm(cpConstraint *constraint);
	TiXmlElement *createPinJointElm(cpPinJoint *constraint);
	TiXmlElement *createSlideJointElm(cpSlideJoint *constraint);
	TiXmlElement *createPivotJointElm(cpPivotJoint *constraint);
	TiXmlElement *createGrooveJointElm(cpGrooveJoint *constraint);
	TiXmlElement *createMotorJointElm(cpSimpleMotor *constraint);
	TiXmlElement *createGearJointElm(cpGearJoint *constraint);
	TiXmlElement *createSpringJointElm(cpDampedSpring *constraint);
	TiXmlElement *createRotaryLimitJointElm(cpRotaryLimitJoint *constraint);
	TiXmlElement *createRatchetJointElm(cpRatchetJoint *constraint);
	TiXmlElement *createRotarySpringJointElm(cpDampedRotarySpring *constraint);
	
	TiXmlElement *createPointElm(const char* name, cpVect pt);
    
private:
    TiXmlDocument _doc;
    
	//For Resolving on read
	//typedef std::map<long, cpShape*> ShapeMap;
	typedef std::map<long, cpBody*> BodyMap;
	
	//ShapeMap _shapeMap;
	BodyMap _bodyMap;
};
