#!/bin/bash

JAVA_DIR=java
PYTHON_DIR=python
NODE_DIR=node
PACKAGE_DIR=package

# Prepare directory structure
echo "Cleaning packaging dir $PACKAGE_DIR..."
if [ -d "$PACKAGE_DIR" ]; then
  rm -rf $PACKAGE_DIR
fi
mkdir package

# Build the java package
echo "Building java lambda package..."
cd $JAVA_DIR
./mvnw package
if [ $? -ne 0 ]; then
  echo "Java package build failed"
  exit -1
fi
cp target/lambda-1.0.jar ../$PACKAGE_DIR/lambda_java.jar
cd ..

# Build the python package
PYTHON_SCRIPT=$PYTHON_DIR/lambda.py
echo "Building python lambda package..."
if [ ! -f "$PYTHON_SCRIPT" ]; then
  echo "Missing Python lambda: $PYTHON_SCRIPT"
  exit -1
fi
zip -X $PACKAGE_DIR/lambda_python.zip $PYTHON_SCRIPT
if [ $? -ne 0 ]; then
  echo "Python package build failed"
  exit -1
fi

# Build the node package
NODE_SCRIPT=$NODE_DIR/lambda.js
echo "Building node lambda package..."
if [ ! -f "$NODE_SCRIPT" ]; then
  echo "Missing node lambda: $NODE_SCRIPT"
  exit -1
fi
zip -X $PACKAGE_DIR/lambda_node.zip $NODE_SCRIPT
if [ $? -ne 0 ]; then
  echo "Node package build failed"
  exit -1
fi

#
