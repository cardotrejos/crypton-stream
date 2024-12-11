export class NotificationService {
  constructor() {
    this.eventSource = null;
    this.listeners = new Set();
  }

  connect() {
    if (this.eventSource) {
      this.eventSource.close();
    }

    this.eventSource = new EventSource('/api/notifications/stream');
    
    this.eventSource.addEventListener('notification', (event) => {
      const notification = JSON.parse(event.data);
      this.notifyListeners(notification);
    });

    this.eventSource.addEventListener('error', (error) => {
      console.error('SSE connection error:', error);
      setTimeout(() => this.connect(), 5000); // Reconnect after 5 seconds
    });
  }

  disconnect() {
    if (this.eventSource) {
      this.eventSource.close();
      this.eventSource = null;
    }
  }

  addListener(callback) {
    this.listeners.add(callback);
  }

  removeListener(callback) {
    this.listeners.delete(callback);
  }

  notifyListeners(notification) {
    this.listeners.forEach(callback => callback(notification));
  }
}

// Example usage in your app:
/*
const notificationService = new NotificationService();

// Connect to SSE stream
notificationService.connect();

// Add a listener to handle notifications
notificationService.addListener((notification) => {
  // Handle the notification (e.g., show a toast, update UI, etc.)
  console.log('New notification:', notification);
});

// Clean up when component unmounts
// notificationService.disconnect();
*/
