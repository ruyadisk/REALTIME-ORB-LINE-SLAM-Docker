#!/usr/bin/env python

import rospy
import cv2
from cv_bridge import CvBridge
from sensor_msgs.msg import Image

def publish_image():
    rospy.init_node('image_publisher', anonymous=True)
    
    # Create publishers for left-top and right-top pieces
    left_image_pub = rospy.Publisher('/camera/left/image_raw', Image, queue_size=10)
    right_image_pub = rospy.Publisher('/camera/right/image_raw', Image, queue_size=10)
    
    bridge = CvBridge()
    
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        rospy.logerr("Error: Could not open video capture.")
        return
    
    # Set the frame size
    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    rospy.loginfo("Camera resolution: %dx%d" % (frame_width, frame_height))
    
    rate = rospy.Rate(30)  # 30 Hz
    
    while not rospy.is_shutdown():
        # Capture frame-by-frame
        ret, frame = cap.read()
        
        if not ret:
            rospy.logwarn("Error: Failed to capture image.")
            break
        
        # Check if the frame is valid
        if frame is None or not frame.size:
            rospy.logwarn("Error: Captured frame is empty or None.")
            continue
        
        # Log the frame size and type
        rospy.loginfo("Captured frame size: %s" % str(frame.shape))
        rospy.loginfo("Frame type: %s" % str(frame.dtype))
        
        # Convert to grayscale if needed
        if len(frame.shape) == 3:  # If the image is colored
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Split the frame into 4 pieces
        height, width = frame.shape
        mid_x = width // 2
        mid_y = height // 2
        
        # Define the four regions
        top_right = frame[0:mid_y, 0:mid_x]
        top_left = frame[0:mid_y, mid_x:width]
        
        # Convert and publish the left-top and right-top pieces
        try:
            left_ros_image = bridge.cv2_to_imgmsg(top_left, encoding="mono8")
            right_ros_image = bridge.cv2_to_imgmsg(top_right, encoding="mono8")
            left_image_pub.publish(left_ros_image)
            right_image_pub.publish(right_ros_image)
        except Exception as e:
            rospy.logerr("Error in converting image: %s" % str(e))
        
        # Sleep to maintain the desired loop rate
        rate.sleep()
    
    # Release the camera when done
    cap.release()

if __name__ == '__main__':
    try:
        publish_image()
    except rospy.ROSInterruptException:
        pass
