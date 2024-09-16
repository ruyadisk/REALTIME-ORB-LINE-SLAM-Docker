import cv2
import time

cap = cv2.VideoCapture(0)

print(cv2.__version__)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    cv2.imshow('123',frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break


cap.release()
cv2.destroyAllWindows()