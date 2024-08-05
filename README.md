# Threads-Gallery-View
This is the code to create a custom gallery view similar to Threads when selecting images or videos for upload.

## Features
1. By default, users can view all recent images.
2. Users can select between the "Recent" or "Video" sections using the dropdown bottom sheet.
3. Albums are displayed in two rows that scroll simultaneously.
4. Users can choose images or videos from various albums.
5. When reopening the gallery, previously selected images and videos will be shown.
6. Users can select up to 10 images or videos at a time.

## Dependencies
<details>
     <summary> Click to expand </summary>
     
* [photo_manager](https://pub.dev/packages/photo_manager)
* [cupertino_icons](https://pub.dev/packages/cupertino_icons)
* [cached_network_image](https://pub.dev/packages/cached_network_image)
     
</details>

## Directory Structure
<details>
     <summary> Click to expand </summary>
  
```
|-- lib
|   |-- models
|   |   |-- asset_model.dart
|   |-- main.dart
|   |-- screens
|   |   |-- widgets
|   |   |   |-- album_summary.dart
|   |   |   |-- album_thumbnail.dart
|   |   |   |-- asset_grid_view.dart
|   |   |   |-- asset_thumbnail.dart
|   |   |-- album_selection_screen.dart
|   |   |-- home_screen.dart
|   |   |-- photo_gallery_screen.dart
|   |-- utils
|   |   |-- asset_thumbnail_cache.dart
|   |   |-- permission_helper.dart
|-- pubspec.yaml
```

</details>

## Contributing

If you wish to contribute a change to any of the existing feature or add new in this repo,
please review our [contribution guide](https://github.com/aditya263/Threads-Gallery-View/blob/main/CONTRIBUTING.md),
and send a [pull request](https://github.com/aditya263/Threads-Gallery-View/pulls). I welcome and encourage all pull requests. It usually will take me within 24-48 hours to respond to any issue or request.


## Feedback

If you have any feedback, please reach out to me at ranjanaditya263@gmail.com

## License

[MIT](https://choosealicense.com/licenses/mit/)
