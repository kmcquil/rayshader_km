#'@title Render High Quality
#'
#'@description Renders a raytraced version of the displayed rgl scene, using the `rayrender` package. 
#'User can specify the light direction, intensity, and color, as well as specify the material of the 
#'ground and add additional scene elements.
#'
#'This function can also generate frames for an animation by passing camera animation information from 
#'either `convert_path_to_animation_coords()` or `rayrender::generate_camera_motion()` functions.
#'
#'@param filename Default `NA`. Filename of saved image. If missing, will display to current device.
#'@param samples Default `128`. The maximum number of samples for each pixel. Increase this to increase the quality of the rendering.
#'@param sample_method Default `"sobol_blue"`, unless `samples > 256`, in which it defaults to `"sobol"`.
#'The type of sampling method used to generate random numbers. 
#'The other options are `random` (worst quality but fastest), 
#'`sobol_blue` (best option for sample counts below 256), and `sobol` 
#'(slowest but best quality, better than `sobol_blue` for sample counts greater than 256).
#'@param min_variance Default `1e-6`. Minimum acceptable variance for a block of pixels for the adaptive sampler. 
#'Smaller numbers give higher quality images, at the expense of longer rendering times. 
#'If this is set to zero, the adaptive sampler will be turned off and the renderer will use the maximum number of samples everywhere.
#'@param light Default `TRUE`. Whether there should be a light in the scene. If not, the scene will be lit with a bluish sky.
#'@param lightdirection Default `315`. Position of the light angle around the scene. 
#'If this is a vector longer than one, multiple lights will be generated (using values from 
#'`lightaltitude`, `lightintensity`, and `lightcolor`)
#'@param lightaltitude Default `45`. Angle above the horizon that the light is located. 
#'If this is a vector longer than one, multiple lights will be generated (using values from 
#'`lightdirection`, `lightintensity`, and `lightcolor`)
#'@param lightsize Default `NULL`. Radius of the light(s). Automatically chosen, but can be set here by the user.
#'@param lightintensity Default `500`. Intensity of the light.
#'@param lightcolor Default `white`. The color of the light.
#'@param water_attenuation Default `0`, no attenuation. Amount that light should be attenuated when traveling through water. This
#'calculates 1-color 
#'@param water_surface_color Default `TRUE`. Whether the water should have a colored surface or not. This is in contrast to
#' setting a non-zero water attenuation, where the color comes from the attenuation of light in the water itself.
#'@param water_ior Default `1`. Water index of refraction.
#'@param material Default `rayrender::diffuse()`. The material properties of the object file. Only used if `override_material = TRUE`
#'@param override_material Default `FALSE`. Whether to override the default diffuse material with that in argument `material`.
#'@param cache_scene Default `FALSE`. Whether to cache the current scene to memory so it does not have to be converted to a `raymesh` object 
#'each time `render_snapshot()` is called. If `TRUE` and a scene has been cached, it will be used when rendering.
#'@param reset_scene_cache Default `FALSE`. Resets the scene cache before rendering.
#'@param width Defaults to the width of the rgl window. Width of the rendering. 
#'@param height Defaults to the height of the rgl window. Height of the rendering. 
#'@param text_angle Default `NULL`, which forces the text always to face the camera. If a single angle (degrees),
#'will specify the absolute angle all the labels are facing. If three angles, this will specify all three orientations
#'(relative to the x,y, and z axes) of the text labels.
#'@param text_size Default `6`. Height of the text.
#'@param text_offset Default `c(0,0,0)`. Offset to be applied to all text labels.
#'@param line_radius Default `0.5`. Radius of line/path segments.
#'@param smooth_line Default `FALSE`. If `TRUE`, the line will be rendered with a continuous smooth line, rather
#'than straight segments.
#'@param use_extruded_paths Default `TRUE`. If `FALSE`, paths will be generated with the `rayrender::path()` object, instead
#'of `rayrender::extruded_path()`.
#'@param point_radius Default `1`. Radius of 3D points (rendered with `render_points()`). This scales the existing
#'value of size specified in `render_points()`.
#'@param scale_text_angle Default `NULL`. Same as `text_angle`, but for the scale bar.
#'@param scale_text_size Default `6`. Height of the scale bar text.
#'@param scale_text_offset Default `c(0,0,0)`. Offset to be applied to all scale bar text labels.
#'@param title_text Default `NULL`. Text. Adds a title to the image, using magick::image_annotate. 
#'@param title_offset Default `c(20,20)`. Distance from the top-left (default, `gravity` direction in 
#'image_annotate) corner to offset the title.
#'@param title_size Default `30`. Font size in pixels.
#'@param title_color Default `black`. Font color.
#'@param title_font Default `sans`. String with font family such as "sans", "mono", "serif", "Times", "Helvetica", 
#'"Trebuchet", "Georgia", "Palatino" or "Comic Sans".
#'@param title_just Default `left`. Justification of the title.
#'@param title_bar_color Default `NA`. If a color, this will create a colored bar under the title.
#'@param title_bar_alpha Default `0.5`. Transparency of the title bar.
#'@param ground_material Default `diffuse()`. Material defined by the rayrender material functions.
#'@param ground_size Default `100000`. The width of the plane representing the ground.
#'@param camera_location Default `NULL`. Custom position of the camera. The `FOV`, `width`, and `height` arguments will still
#'be derived from the rgl window.
#'@param camera_lookat Default `NULL`. Custom point at which the camera is directed. The `FOV`, `width`, and `height` arguments will still
#'be derived from the rgl window.
#'@param camera_interpolate Default `c(0,0)`. Maximum `1`, minimum `0`. Sets the camera at a point between the `rgl` view and the `camera_location` 
#'and `camera_lookat` vectors.
#'@param scene_elements Default `NULL`. Extra scene elements to add to the scene, created with rayrender.
#'@param clear Default `FALSE`. If `TRUE`, the current `rgl` device will be cleared.
#'@param print_scene_info Default `FALSE`. If `TRUE`, it will print the position and lookat point of the camera.
#'@param clamp_value Default `10`. See documentation for `rayrender::render_scene()`.
#'@param return_scene Default `FALSE`. If `TRUE`, this will return the rayrender scene (instead of rendering the image).
#'@param load_normals Default `TRUE`. Whether to load the vertex normals if they exist in the OBJ file.
#'@param calculate_consistent_normals Default `FALSE`. Whether to calculate consistent vertex normals to prevent energy 
#'loss at edges.
#'@param point_material Default `rayrender::diffuse`. The rayrender material function to be applied
#'to point data.
#'@param point_material_args Default empty `list()`. The function arguments to `point_material`. 
#'The argument `color` will be automatically extracted from the rgl scene, but all other arguments 
#'can be specified here. 
#'@param path_material Default `rayrender::diffuse`. The rayrender material function to be applied
#'to path data.
#'@param path_material_args Default empty `list()`. The function arguments to `path_material`. 
#'The argument `color` will be automatically extracted from the rgl scene, but all other arguments 
#'can be specified here. 
#'@param animation_camera_coords Default `NULL`. Expects camera animation output from either `convert_path_to_animation_coords()`
#'or `rayrender::generate_camera_motion()` functions.
#'@param ... Additional parameters to pass to `rayrender::render_scene`()
#'
#'@export
#'@examples
#'#Render the volcano dataset using pathtracing
#'if(run_documentation()) {
#'volcano %>%
#'  sphere_shade() %>%
#'  plot_3d(volcano,zscale = 2)
#'render_highquality(min_variance = 0, sample_method = "sobol_blue") 
#'}
#'
#'#Change position of light
#'if(run_documentation()) {
#'render_highquality(lightdirection = 45, min_variance = 0, sample_method = "sobol_blue")
#'}
#'
#'#Change vertical position of light
#'if(run_documentation()) {
#'render_highquality(lightdirection = 45, lightaltitude = 10, 
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
#'
#'#Change the ground material
#'if(run_documentation()) {
#'render_highquality(lightdirection = 45, lightaltitude=60,
#'                   ground_material = rayrender::diffuse(checkerperiod = 30, checkercolor="grey50"),
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
#'
#'#Add three different color lights and a title
#'if(run_documentation()) {
#'render_highquality(lightdirection = c(0,120,240), lightaltitude=45,
#'                   lightcolor=c("red","green","blue"), title_text = "Red, Green, Blue",
#'                   title_bar_color="white", title_bar_alpha=0.8,
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
#'
#'#Change the camera:
#'if(run_documentation()) {
#'render_camera(theta=-45,phi=60,fov=60,zoom=0.8)
#'render_highquality(lightdirection = c(0),
#'                   title_bar_color="white", title_bar_alpha=0.8,
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
#'#Add a shiny metal sphere
#'if(run_documentation()) {
#'render_camera(theta=-45,phi=60,fov=60,zoom=0.8)
#'render_highquality(lightdirection = c(0,120,240), lightaltitude=45, 
#'                   lightcolor=c("red","green","blue"),
#'                   scene_elements = rayrender::sphere(z=-60,y=0,
#'                                                      radius=20,material=rayrender::metal()),
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
#'
#'#Add a red light to the volcano and change the ambient light to dusk
#'if(run_documentation()) {
#'render_camera(theta=45,phi=45)
#'render_highquality(lightdirection = c(240), lightaltitude=30, 
#'                   lightcolor=c("#5555ff"),
#'                   scene_elements = rayrender::sphere(z=0,y=15, x=-18, radius=5,
#'                                    material=rayrender::light(color="red",intensity=10)),
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
#'#Manually change the camera location and direction
#'if(run_documentation()) {
#'render_camera(theta=45,phi=45,fov=90)
#'render_highquality(lightdirection = c(240), lightaltitude=30, lightcolor=c("#5555ff"), 
#'                   camera_location = c(50,10,10), camera_lookat = c(0,15,0),
#'                   scene_elements = rayrender::sphere(z=0,y=15, x=-18, radius=5,
#'                                    material=rayrender::light(color="red",intensity=10)),
#'                   min_variance = 0, sample_method = "sobol_blue")
#'}
render_highquality = function(filename = NA, samples = 128, 
                              sample_method = "sobol_blue", min_variance=1e-7,
                              light = TRUE, 
                              lightdirection = 315, lightaltitude = 45, lightsize=NULL,
                              lightintensity = 500, lightcolor = "white", material = rayrender::diffuse(),
                              water_attenuation = 0, water_surface_color = TRUE, water_ior = 1,
                              override_material = FALSE,
                              cache_scene = FALSE, reset_scene_cache = FALSE, 
                              width = NULL, height = NULL, 
                              text_angle = NULL, text_size = 12, text_offset = c(0,text_size/2,0), 
                              line_radius=0.5, point_radius = 0.5, smooth_line = FALSE,
                              use_extruded_paths = FALSE,
                              scale_text_angle = NULL, scale_text_size = 12, scale_text_offset = c(0,scale_text_size/2,0), 
                              title_text = NULL, title_offset = c(20,20), 
                              title_color = "black", title_size = 30, title_font = "sans",
                              title_just = "left",
                              title_bar_color = NA, title_bar_alpha = 0.5,
                              ground_material = rayrender::diffuse(), ground_size=100000,
                              scene_elements=NULL, 
                              camera_location = NULL, camera_lookat = NULL, 
                              camera_interpolate=1, clear  = FALSE, return_scene = FALSE,
                              print_scene_info = FALSE, clamp_value = 10, 
                              calculate_consistent_normals = FALSE, load_normals = TRUE,
                              point_material = rayrender::diffuse, 
                              point_material_args = list(),
                              path_material = rayrender::diffuse, 
                              path_material_args = list(),
                              animation_camera_coords = NULL, ...) {
  if(rgl::cur3d() == 0) {
    stop("No rgl window currently open.")
  }
  if(samples > 256 && sample_method == "sobol_blue") {
    warning(r"{When `sample_method = "sobol_blue"`, `samples` must be less than or equal to 256. Setting `sample_method` to `"sobol"`.}")
    sample_method = "sobol"
  }
  if(reset_scene_cache) {
    assign("scene_cache", NULL, envir = ray_cache_scene_envir)
  }
  if(!is.na(filename)) {
    if(dirname(filename) != ".") {
      if(!dir.exists(dirname(filename))) {
        stop(sprintf("Error: directory '%s' does not exist.", dirname(filename)))
      }
    }
  }
  if(!(length(find.package("rayrender", quiet = TRUE)) > 0)) {
    stop("`rayrender` package required for render_highquality()")
  }
  
  #Check path/point material arguments
  if(!inherits(path_material, "function")) {
    stop("`path_material` is not a function: did you forget to remove the `()` at the end?")
  }
  arg_names = names(formals(path_material))
  not_matching = !(names(path_material_args) %in% arg_names)
  if(any(not_matching)) {
    arg_names = arg_names[arg_names != "color"]
    all_arg_names = paste(arg_names, collapse = ", ")
    all_not_matching = paste(names(path_material_args)[not_matching], collapse = ", ")
    stop(sprintf("Path material arguments `%s` not valid for the material. Valid argument names are: \n%s", 
                 all_not_matching, all_arg_names))
  }
  if(!inherits(point_material, "function")) {
    stop("`point_material` is not a function: did you forget to remove the `()` at the end?")
  }
  arg_names = names(formals(point_material))
  not_matching = !(names(point_material_args) %in% arg_names)
  if(any(not_matching)) {
    arg_names = arg_names[arg_names != "color"]
    all_arg_names = paste(arg_names, collapse = ", ")
    all_not_matching = paste(names(point_material_args)[not_matching], collapse = ", ")
    stop(sprintf("Point material arguments `%s` not valid for the material. Valid argument names are: \n%s", 
                 all_not_matching, all_arg_names))
  }
  #Set use_extruded_path to TRUE if path_material is dielectric
  path_material_raw = path_material()
  path_material_df = path_material_raw[[1]]
  if(path_material_df$type == "dielectric" && !use_extruded_paths) {
    message("dielectric material for paths selected--setting `use_extruded_paths = TRUE` for accurate rendering of material")
    use_extruded_paths = TRUE
  }

  #Get scene info
  windowrect = rgl::par3d()$windowRect
  if(!is.null(title_text)) {
    has_title = TRUE
  } else {
    has_title = FALSE
  }
  if(is.null(width)) {
    width = windowrect[3]-windowrect[1]
  }
  if(is.null(height)) {
    height = windowrect[4]-windowrect[2]
  }
  if(.Platform$OS.type == "windows") {
    sepval = "\\"
  } else {
    sepval = "/"
  }

  surfaceid = get_ids_with_labels(typeval = c("surface", "surface_tris"))
  surfacevertices = rgl.attrib(surfaceid$id[1], "vertices")
  polygonid = get_ids_with_labels(typeval = c("polygon3d"))
  baseid = get_ids_with_labels(typeval = c("base"))
  if(nrow(polygonid) > 0) {
    polyrange = c()
    polyrange_x = c()
    polyrange_z = c()
    for(i in seq_len(nrow(polygonid))) {
      tempverts = range(rgl.attrib(polygonid$id[i], "vertices")[,2])
      tempverts_x = range(rgl.attrib(polygonid$id[i], "vertices")[,1])
      tempverts_z = range(rgl.attrib(polygonid$id[i], "vertices")[,3])
      
      if(all(!is.na(tempverts))) {
        polyrange = range(c(tempverts,polyrange))
      }
      if(all(!is.na(tempverts_x))) {
        polyrange_x = range(c(tempverts_x,polyrange_x))
      }
      if(all(!is.na(tempverts_z))) {
        polyrange_z = range(c(tempverts_z,polyrange_z))
      }
    }
  }
  if(nrow(baseid) > 0) {
    baserange = c()
    for(i in seq_len(nrow(baseid))) {
      tempverts = range(rgl.attrib(baseid$id[i], "vertices")[,2])
      if(all(!is.na(tempverts))) {
        baserange = range(c(tempverts,baserange))
      }
    }
  }
  surfacerange = range(surfacevertices[,2],na.rm=TRUE)
  if(nrow(polygonid) > 0) {
    surfacerange[2] = range(c(surfacerange,polyrange))[2]
  }
  if(nrow(baseid) > 0) {
    surfacerange[2] = range(c(surfacerange,baserange))[2]
  }
  shadowid = get_ids_with_labels(typeval = "shadow")
  if(nrow(shadowid) > 0) {
    shadowvertices = rgl.attrib(shadowid$id[1], "vertices")
    shadowdepth = shadowvertices[1,2]
    has_shadow = TRUE
  } else {
    has_shadow = FALSE
  }
  camera_interpolate[camera_interpolate > 1] = 1
  camera_interpolate[camera_interpolate < 0] = 0
  fov = rgl::par3d()$FOV
  rotmat = rot_to_euler(rgl::par3d()$userMatrix)
  projmat = rgl::par3d()$projMatrix
  zoom = rgl::par3d()$zoom
  scalevals = rgl::par3d("scale")
  
  phi = rotmat[1]
  if(90 - abs(phi) < 1e-3) {
    phi = -phi
  }
  if(0.001 > abs(abs(rotmat[3]) - 180)) {
    theta = -rotmat[2] + 180
    movevec = rgl::rotationMatrix(-rotmat[2]*pi/180, 0, 1, 0) %*%
      rgl::rotationMatrix(-phi*pi/180, 1, 0, 0) %*% 
      rgl::par3d()$userMatrix[,4]
  } else {
    theta = rotmat[2]
    movevec = rgl::rotationMatrix(rotmat[3]*pi/180, 0, 0, 1) %*%
      rgl::rotationMatrix(rotmat[2]*pi/180, 0, 1, 0) %*%
      rgl::rotationMatrix(-phi*pi/180, 1, 0, 0) %*% 
      rgl::par3d()$userMatrix[,4]
  }
  movevec = movevec[1:3]
  observer_radius = rgl::par3d()$observer[3]
  lookvals = rgl::par3d()$bbox
  # lookvals[4] = surfacerange[2]
  if(fov == 0) {
    ortho_dimensions = c(2/projmat[1,1],2/projmat[2,2])
  } else {
    fov = 2 * atan(1/projmat[2,2]) * 180/pi
    ortho_dimensions = c(1,1)
  }
  bbox_center = c(mean(lookvals[1:2]),mean(lookvals[3:4]),mean(lookvals[5:6])) - movevec
  observery = sinpi(phi/180) * observer_radius
  observerx = cospi(phi/180) * sinpi(theta/180) * observer_radius
  observerz = cospi(phi/180) * cospi(theta/180) * observer_radius
  if(is.null(camera_location)) {
    lookfrom = c(observerx, observery, observerz) 
  } else {
    lookfrom = camera_location
  }
  if(length(camera_interpolate) == 1) {
    camera_interpolate = c(camera_interpolate,camera_interpolate)
  }
  if(is.null(camera_lookat)) {
    camera_lookat = c(0,0,0)
  }
  if(all(camera_interpolate != 1)) {
    if(!is.null(camera_location)) {
      lookfrom = (1-camera_interpolate[1]) * c(observerx, observery, observerz) + 
        camera_interpolate[1] * camera_location
    }
    if(!is.null(camera_lookat)) {
      camera_lookat = camera_interpolate[2] * camera_lookat
    }
  }
  water_attenuation = abs(water_attenuation)
  if(any(water_attenuation > 1)) {
    warnings("`water_attenuation` should only be a value of 1 or less--clamping at 0-1")
    water_attenuation[water_attenuation > 1] = 1
  }
  if(cache_scene) {
    ray_scene = get("scene_cache", envir = ray_cache_scene_envir)
    if(is.null(ray_scene)) {
      ray_scene = convert_rgl_to_raymesh(save_shadow = FALSE, 
        water_attenuation = water_attenuation,
        water_surface_color = water_surface_color, water_ior = water_ior)
      assign("scene_cache", ray_scene, envir = ray_cache_scene_envir)
    }
  } else {
    ray_scene = convert_rgl_to_raymesh(save_shadow = FALSE, 
      water_attenuation = water_attenuation,
      water_surface_color = water_surface_color, water_ior = water_ior)
  }
  
  if(!override_material) {
    scene = rayrender::raymesh_model(ray_scene,
                                     x = -bbox_center[1],
                                     y = -bbox_center[2],
                                     z = -bbox_center[3],
                                     override_material = FALSE, flip_transmittance = FALSE,
                                     calculate_consistent_normals = calculate_consistent_normals)
  } else {
    scene = rayrender::raymesh_model(ray_scene,
                                     x = -bbox_center[1],
                                     y = -bbox_center[2],
                                     z = -bbox_center[3],
                                     material = material,
                                     override_material = TRUE, flip_transmittance = FALSE,
                                     calculate_consistent_normals = calculate_consistent_normals)
  }
  has_rayimage = TRUE
  if(!(length(find.package("rayimage", quiet = TRUE)) > 0)) {
    warning("`rayimage` package required for labels")
    has_rayimage = FALSE
  }
  labelids = get_ids_with_labels(typeval = "raytext")$id
  labels = list()
  counter = 1
  for(i in seq_len(length(labelids))) {
    if(!has_rayimage) {
      break
    }
    temp_label = rgl.attrib(labelids[i], "texts")
    temp_center = rgl.attrib(labelids[i], "centers")
    temp_color = rgl.attrib(labelids[i], "colors")
    for(j in seq_len(nrow(temp_label))) {
      if(is.null(text_angle)) {
        anglevec = c(-phi,theta,0)
      } else {
        if(length(text_angle) == 1) {
          anglevec = c(0,text_angle,0)
        } else {
          anglevec = text_angle
        }
      }
      labels[[counter]] = rayrender::text3d(label=temp_label[j,1],
                                  x=temp_center[j,1] - bbox_center[1] + text_offset[1], 
                                  y=temp_center[j,2] - bbox_center[2] + text_offset[2], 
                                  z=temp_center[j,3] - bbox_center[3] + text_offset[3],
                                  angle = anglevec, 
                                  text_height = text_size, font_color =  temp_color[j,1:3])
      counter = counter + 1
    }
  }
  if(length(labels) > 0) {
    all_labels = do.call(rbind, labels)
    scene = rayrender::add_object(scene, all_labels)
  }
  labellineids = get_ids_with_labels(typeval = "textline")$id
  labelline = list()
  counter = 1
  for(i in seq_len(length(labellineids))) {
    if(!has_rayimage) {
      break
    }
    temp_verts = rgl.attrib(labellineids[i], "vertices")
    temp_color = rgl.attrib(labellineids[i], "colors")
    for(j in seq_len(nrow(temp_verts)/2)) {
      labelline[[counter]] = rayrender::segment(start = temp_verts[2*j-1,] - bbox_center, 
                                     end   = temp_verts[2*j,] - bbox_center,
                                     radius = line_radius,
                                     material = rayrender::diffuse(color = temp_color[j,1:3]))
      counter = counter + 1
    }
  }
  pathids = get_ids_with_labels(typeval = c("path3d","contour3d"))$id
  pathline = list()
  counter = 1
  for(i in seq_len(length(pathids))) {
    temp_verts = rgl.attrib(pathids[i], "vertices")
    temp_verts_split = split(as.data.frame(temp_verts),
                             cumsum(apply(temp_verts,1,\(x) any(is.na(x)))))
    for(j in seq_along(temp_verts_split)[-1]) {
      temp_verts_split[[j]] = temp_verts_split[[j]][-1,]
    }
    temp_color = rgl.attrib(pathids[i], "colors")
    temp_lwd = material3d("lwd", id = pathids[i]) * line_radius
    for(j in seq_along(temp_verts_split)) {
      temp_verts_single = temp_verts_split[[j]]
      if(nrow(temp_color) == 1) {
        temp_color = matrix(temp_color[1:3], byrow = TRUE, ncol = 3, nrow = nrow(temp_verts_single))
      }
      matrix_center = matrix(bbox_center, byrow=TRUE,ncol=3,nrow = nrow(temp_verts_single))
      path_material_args$color = temp_color[1,1:3]
      
      if(use_extruded_paths) {
        pathline[[counter]] = rayrender::extruded_path(points = temp_verts_single - matrix_center , 
                                              width = temp_lwd * 2,
                                              smooth_normals = TRUE, 
                                              straight = !smooth_line,
                                              material = do.call("path_material", args = path_material_args))
      } else {
        pathline[[counter]] = rayrender::path(points = temp_verts_single - matrix_center, 
                                              width = temp_lwd * 2,
                                              straight = !smooth_line,
                                              material = do.call("path_material", args = path_material_args))
      }
      counter = counter + 1
    }
  }
  pointids = get_ids_with_labels(typeval = "points3d")$id
  pointlist = list()
  counter = 1
  for(i in seq_len(length(pointids))) {
    temp_verts = rgl.attrib(pointids[i], "vertices")
    temp_color = rgl.attrib(pointids[i], "colors")
    temp_size = material3d("size", id = pointids[i]) * point_radius
    if(nrow(temp_color) == 1) {
      temp_color = matrix(temp_color[1:3], byrow = TRUE, ncol = 3, nrow = nrow(temp_verts))
    }
    for(j in seq_len(nrow(temp_verts))) {
      point_material_args$color = temp_color[j,1:3]
      
      pointlist[[counter]] = rayrender::sphere(x = temp_verts[j,1] - bbox_center[1],
                                              y = temp_verts[j,2] - bbox_center[2],
                                              z = temp_verts[j,3] - bbox_center[3],
                                              radius = temp_size,
                                              material = do.call("point_material", args = point_material_args))
      counter = counter + 1
    }
  }
  scalelabelids = get_ids_with_labels(typeval = "text_scalebar")$id
  scalelabels = list()
  counter = 1
  for(i in seq_len(length(scalelabelids))) {
    if(!has_rayimage) {
      break
    }
    temp_label = rgl.attrib(scalelabelids[i], "texts")
    temp_center = rgl.attrib(scalelabelids[i], "centers")
    temp_color = rgl.attrib(scalelabelids[i], "colors")
    for(j in seq_len(nrow(temp_label))) {
      if(is.null(text_angle)) {
        anglevec = c(-phi,theta,0)
      } else {
        if(length(text_angle) == 1) {
          anglevec = c(0,text_angle,0)
        } else {
          anglevec = text_angle
        }
      }
      scalelabels[[counter]] = rayrender::text3d(x=temp_center[j,1] - bbox_center[1] + scale_text_offset[1], 
                                  y=temp_center[j,2] - bbox_center[2] + scale_text_offset[2], 
                                  z=temp_center[j,3] - bbox_center[3] + scale_text_offset[3],
                                  angle = anglevec, label = temp_label,
                                  text_height = scale_text_size, font_color = temp_color[j,1:3])
      counter = counter + 1
    }
  }
  if(length(labels) > 0) {
    all_labels = do.call(rbind, labels)
    scene = rayrender::add_object(scene, all_labels)
  }
  if(length(labelline) > 0) {
    all_labellines = do.call(rbind, labelline)
    scene = rayrender::add_object(scene, all_labellines)
  }
  if(length(scalelabels) > 0) {
    all_scalelabels = do.call(rbind, scalelabels)
    scene = rayrender::add_object(scene, all_scalelabels)
  }
  if(length(pathline) > 0) {
    all_pathline = do.call(rbind, pathline)
    scene = rayrender::add_object(scene, all_pathline)
  }
  if(length(pointlist) > 0) {
    all_pointlist = do.call(rbind, pointlist)
    scene = rayrender::add_object(scene, all_pointlist)
  }
  if(has_shadow) {
    scene = rayrender::add_object(scene, rayrender::xz_rect(zwidth=ground_size,xwidth=ground_size,
                                                            y=shadowdepth-bbox_center[2], material = ground_material))
  }
  if(any(round(scalevals,4) != 1)) {
    scene = rayrender::group_objects(scene, 
                                     scale = scalevals, 
                                     pivot_point = c(0,0,0))
  }
  if(light) {
    if(is.null(lightsize)) {
      lightsize = observer_radius/5
    }
    if(length(lightaltitude) >= 1 || length(lightdirection) >= 1) {
      if(length(lightaltitude) > 1 && length(lightdirection) > 1 && length(lightdirection) != length(lightaltitude)) {
        stop("lightaltitude vector ", lightaltitude, " and lightdirection vector ", lightdirection, "both greater than length 1 but not equal length" )
      }
      numberlights = ifelse(length(lightaltitude) > length(lightdirection), length(lightaltitude),length(lightdirection))
      lightaltitudetemp = lightaltitude[1]
      lightdirectiontemp = lightdirection[1]
      lightintensitytemp = lightintensity[1]
      lightcolortemp = lightcolor[1]
      lightsizetemp = lightsize[1]
      for(i in seq_len(numberlights)) {
        if(!is.na(lightaltitude[i])) {
          lightaltitudetemp = lightaltitude[i]
        }
        if(!is.na(lightdirection[i])) {
          lightdirectiontemp = lightdirection[i]
        }
        if(!is.na(lightintensity[i])) {
          lightintensitytemp = lightintensity[i]
        }
        if(!is.na(lightcolor[i])) {
          lightcolortemp = lightcolor[i]
        }
        if(!is.na(lightsize[i])) {
          lightsizetemp = lightsize[i]
        }
        scene = rayrender::add_object(scene, rayrender::sphere(x=observer_radius*5 * cospi(lightaltitudetemp/180) * sinpi(lightdirectiontemp/180),
                                         y=observer_radius*5 * sinpi(lightaltitudetemp/180),
                                         z=-observer_radius*5 * cospi(lightaltitudetemp/180) * cospi(lightdirectiontemp/180), radius=lightsizetemp,
                                         material = rayrender::light(color = lightcolortemp, intensity = lightintensitytemp)))
      }
    }
  }
  if(print_scene_info) {
    dist_val = sqrt(sum((camera_lookat - lookfrom)^2))
    print(sprintf("Camera position: c(%0.2f, %0.2f, %0.2f), Camera Lookat: c(%0.2f, %0.2f, %0.2f) Focal Distance: %0.2f Scene Offset:  c(%0.2f, %0.2f, %0.2f)",
                  lookfrom[1],lookfrom[2],lookfrom[3], camera_lookat[1], camera_lookat[2], camera_lookat[3], dist_val,
                  -bbox_center[1],-bbox_center[2],-bbox_center[3]))
  }
  if(!is.null(scene_elements)) {
    scene = rayrender::add_object(scene,scene_elements)
  }
  if(return_scene) {
    return(scene)
  }
  
  if(!is.null(animation_camera_coords)) {
    stopifnot(ncol(animation_camera_coords) == 14)
    rayrender::render_animation(scene, camera_motion = animation_camera_coords, width = width, height = height,
                                min_variance = min_variance, samples = samples, sample_method = sample_method,
                                filename = filename, clamp_value = clamp_value, ...)
    return()
  }
  
  if(has_title) {
    temp = tempfile(fileext = ".png")
    debug_return = rayrender::render_scene(scene, lookfrom = lookfrom, lookat = camera_lookat, fov = fov, filename=temp,
                                           min_variance = min_variance, samples = samples, sample_method = sample_method,
                 ortho_dimensions = ortho_dimensions, width = width, height = height,  #camera_up = camera_up,
                 clamp_value = clamp_value, ...)
    if(has_title) {
      if(is.na(filename)) {
        temp = rayimage::ray_read_image(temp)
        rayimage::render_title(temp, title_text = title_text, title_color = title_color, 
                            title_font = title_font, title_offset = title_offset,  
                            title_just = title_just,
                            title_bar_alpha =  title_bar_alpha, title_bar_color = title_bar_color,
                            title_size = title_size, preview = TRUE)
      } else {
        temp = rayimage::ray_read_image(temp)
        rayimage::render_title(temp, title_text = title_text, title_color = title_color, 
                            title_font = title_font, title_offset = title_offset, 
                            title_just = title_just,
                            title_bar_alpha =  title_bar_alpha, title_bar_color = title_bar_color,
                            title_size = title_size, filename = filename)
      }
    }
  } else {
    if(!is.na(filename)) {
      debug_return = rayrender::render_scene(scene, lookfrom = lookfrom, lookat = camera_lookat, fov = fov, filename=filename,
                                             min_variance = min_variance, samples = samples, sample_method = sample_method,
                   ortho_dimensions = ortho_dimensions, width = width, height = height, #camera_up = camera_up,
                   clamp_value = clamp_value, ...)
    } else {
      debug_return = rayrender::render_scene(scene, lookfrom = lookfrom, lookat = camera_lookat, fov = fov, 
                                             min_variance = min_variance, samples = samples, sample_method = sample_method,
                                             ortho_dimensions = ortho_dimensions, width = width, height = height, #camera_up = camera_up,
                                             clamp_value = clamp_value, ...)
    }
  }
  if(clear) {
    rgl::clear3d()
  }
  return(invisible(debug_return))
}
