# somehting fun

### [many changes were here]

### [follow up]:

feat: enhance node interactions and dynamic color calculations

- Add double-tap gesture in NodeView to trigger editable details modal
  - Implement onDoubleTap callback in MainCanvasView for node selection
  - Present TodoDetailView modal for editing title, description, deadline, and status
- Implement dynamic child node coloring based on time progression
  - Create childColor() helper using gray palette with time ratio calculation
  - Add timer to update colors every second and propagate to parents
- Introduce parent node color mixing through child color averaging
  - Add mixColors() helper function for parent color calculation
- Improve date/time selection in creation views
  - Update ChildNodeCreationView and ParentNodeCreationView with combined DatePickers
- Enhance text visibility with contrast color calculation
  - Integrate contrastingColor() helper in NodeView for foreground colors

### Demos

on desktop:

https://github.com/user-attachments/assets/697d3d40-fc18-4d68-a3d2-7298df8aed32

on mobile:

https://github.com/user-attachments/assets/db9d9307-80d9-45b1-893d-dd1f7ac596b6
