# GridView

A grid view for iOS, based on NSGridView for macOS.

## Examples

Go to [Example/GridViewExample](https://github.com/roblokhorst/GridView/tree/master/Example/GridViewExample) to view some examples.

## Todo

- Fix runtime ambiguous position and size
- Fix `mergeCells` (don't save ranges, but actually merge cells somehow)
- Implement all properties and methods that NSGridView has
- Update defaults to NSGridView defaults
- `translatesAutoresizingMaskIntoConstraints` should be true by default
- Add all contentViews as subviews before activating `customPlacementConstraints`
- Remove constraint when nilling out `.width` or `.height`
- Make `UIView.animate` possible, by not using `updateGrid()`
- Convenience methods in pod extension
