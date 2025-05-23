#'@title Transform ggplot2 objects into 3D
#'
#'@description Plots a ggplot2 object in 3D by mapping the color or fill aesthetic to elevation.
#'
#'Currently, this function does not transform lines mapped to color into 3D.
#'
#'If there are multiple legends/guides due to multiple aesthetics being mapped (e.g. color and shape),
#'the package author recommends that the user pass the order of the guides manually using the ggplot2 function "guides()`. 
#'Otherwise, the order may change when processing the ggplot2 object and result in a mismatch between the 3D mapping
#'and the underlying plot.
#'
#'Using the shape aesthetic with more than three groups is not recommended, unless the user passes in 
#'custom, solid shapes. By default in ggplot2, only the first three shapes are solid, which is a requirement to be projected
#'into 3D.
#'
#'@param ggobj ggplot object to projected into 3D. 
#'@param ggobj_height Default `NULL`. A ggplot object that can be used to specify the 3D extrusion separately from the
#'`ggobj`. 
#'@param width Default `3`. Width of ggplot, in `units`.
#'@param height Default `3`. Height of ggplot, in `units`.
#'@param height_aes Default `NULL`. Whether the `fill` or `color` aesthetic should be used for height values, 
#'which the user can specify by passing either `fill` or `color` to this argument.
#'Automatically detected. If both `fill` and `color` aesthetics are present, then `fill` is default.
#'@param invert Default `FALSE`. If `TRUE`, the height mapping is inverted.
#'@param shadow_intensity Default `0.5`. The intensity of the calculated shadows.
#'@param units Default `in`. One of c("in", "cm", "mm").
#'@param scale Default `150`. Multiplier for vertical scaling: a higher number increases the height
#'of the 3D transformation.
#'@param pointcontract Default `0.7`. This multiplies the size of the points and shrinks
#'them around their center in the 3D surface mapping. Decrease this to reduce color bleed on edges, and set to
#'`1` to turn off entirely. Note: If `size` is passed as an aesthetic to the same geom
#'that is being mapped to elevation, this scaling will not be applied. If `alpha` varies on the variable 
#'being mapped, you may want to set this to `1`, since the points now have a non-zero width stroke outline (however,
#'mapping `alpha` in the same variable you are projecting to height is probably not a good choice. as the `alpha`
#'variable is ignored when performing the 3D projection).
#'@param offset_edges Default `FALSE`. If `TRUE`, inserts a small amount of space between polygons for "geom_sf", "geom_tile", "geom_hex", and "geom_polygon" layers.
#'If you pass in a number, the space between polygons will be a line of that width. You can also specify a number to control the thickness of the offset. 
#'Note: this feature may end up removing thin polygons from the plot entirely--use with care.
#'@param flat_plot_render Default `FALSE`. Whether to render a flat version of the ggplot above (or alongside) the 3D version.
#'@param flat_distance Default `"auto"`. Distance to render the flat version of the plot from the 3D version.
#'@param flat_transparent_bg Default `FALSE`. Whether to set the background of the flat version of the ggplot to transparent.
#'@param flat_direction Default `"-z"`. Direction to render the flat copy of the plot, if `flat_plot_render = TRUE`.
#'Other options `c("z", "x", "-x", "y", "-y")`.
#'@param shadow Default `TRUE`. If `FALSE`, no shadow is rendered.
#'@param shadowdepth Default `auto`, which sets it to `soliddepth - soliddepth/10`. Depth of the shadow layer.
#'@param shadow_darkness Default `0.5`. Darkness of the shadow, if `shadowcolor = "auto"`.
#'@param shadowcolor Default `auto`. Color of the shadow, automatically computed as `shadow_darkness`
#'the luminance of the `background` color in the CIELab colorspace if not specified.
#'@param background Default `"white"`. Background color.
#'@param preview Default `FALSE`. If `TRUE`, the raytraced 2D ggplot will be displayed on the current device.
#'@param raytrace Default `FALSE`. Whether to add a raytraced layer.
#'@param sunangle Default `315` (NW). If raytracing, the angle (in degrees) around the matrix from which the light originates. 
#'@param anglebreaks Default `seq(30,40,0.1)`. The azimuth angle(s), in degrees, as measured from the horizon from which the light originates.
#'@param lambert Default `TRUE`. If raytracing, changes the intensity of the light at each point based proportional to the
#'dot product of the ray direction and the surface normal at that point. Zeros out all values directed away from
#'the ray.
#'@param triangulate Default `FALSE`. Reduce the size of the 3D model by triangulating the height map.
#'Set this to `TRUE` if generating the model is slow, or moving it is choppy. Will also reduce the size
#'of 3D models saved to disk.
#'@param max_error Default `0.001`. Maximum allowable error when triangulating the height map,
#'when `triangulate = TRUE`. Increase this if you encounter problems with 3D performance, want
#'to decrease render time with `render_highquality()`, or need 
#'to save a smaller 3D OBJ file to disk with `save_obj()`,
#'@param max_tri Default `0`, which turns this setting off and uses `max_error`. 
#'Maximum number of triangles allowed with triangulating the
#'height map, when `triangulate = TRUE`. Increase this if you encounter problems with 3D performance, want
#'to decrease render time with `render_highquality()`, or need 
#'to save a smaller 3D OBJ file to disk with `save_obj()`,
#'@param verbose Default `TRUE`, if `interactive()`. Prints information about the mesh triangulation
#'if `triangulate = TRUE`.
#'@param emboss_text Default `0`, max `1`. Amount to emboss the text, where `1` is the tallest feature in the scene.
#'@param emboss_grid Default `0`, max `1`. Amount to emboss the grid lines, where `1` is the tallest feature in the scene.
#'By default, the minor grid lines will be half the size of the major lines. Pass a length-2 vector to specify them seperately (second value 
#'is the minor grid height).
#'@param reduce_size Default `NULL`. A number between `0` and `1` that specifies how much to reduce the resolution of the plot, for faster plotting. By
#'default, this just decreases the size of height map, not the image. If you wish the image to be reduced in resolution as well, pass a numeric vector of size 2.
#'@param multicore Default `FALSE`. If raytracing and `TRUE`, multiple cores will be used to compute the shadow matrix. By default, this uses all cores available, unless the user has
#'set `options("cores")` in which the multicore option will only use that many cores.
#'@param save_height_matrix Default `FALSE`. If `TRUE`, the function will return the height matrix used for the ggplot.
#'@param save_shadow_matrix Default `FALSE`. If `TRUE`, the function will return the shadow matrix for use in future updates via the `shadow_cache` argument passed to `ray_shade`.
#'@param saved_shadow_matrix Default `NULL`. A cached shadow matrix (saved by the a previous invocation of `plot_gg(..., save_shadow_matrix=TRUE)` to use instead of raytracing a shadow map each time.
#'@param ... Additional arguments to be passed to `plot_3d()`.
#'@return Opens a 3D plot in rgl.
#'@export
#'@examples
#'library(ggplot2)
#'library(viridis)
#'\dontshow{
#'options("cores"=2)
#'}
#'
#'ggdiamonds = ggplot(diamonds, aes(x, depth)) +
#'  stat_density_2d(aes(fill = after_stat(nlevel)), geom = "polygon", 
#'                  n = 200, bins = 50,contour = TRUE) +
#'  facet_wrap(clarity~.) +
#'  scale_fill_viridis_c(option = "A")
#'if(run_documentation()) {
#'plot_gg(ggdiamonds,multicore = TRUE,width=5,height=5,scale=250,windowsize=c(1400,866),
#'        zoom = 0.55, phi = 30)
#'render_snapshot()
#'}
#'#Change the camera angle and take a snapshot:
#'if(run_documentation()) {
#'render_camera(zoom=0.5,theta=-30,phi=30)
#'render_snapshot()
#'}
#'
#'#Contours and other lines will automatically be ignored. Here is the volcano dataset:
#'ggvolcano = volcano %>% 
#'  reshape2::melt() %>%
#'  ggplot() +
#'  geom_tile(aes(x=Var1,y=Var2,fill=value)) +
#'  geom_contour(aes(x=Var1,y=Var2,z=value),color="black") +
#'  scale_x_continuous("X",expand = c(0,0)) +
#'  scale_y_continuous("Y",expand = c(0,0)) +
#'  scale_fill_gradientn("Z",colours = terrain.colors(10)) +
#'  coord_fixed() + 
#'  theme(legend.position = "none")
#'ggvolcano
#'
#'if(run_documentation()) {
#'plot_gg(ggvolcano, multicore = TRUE, raytrace = TRUE, width = 7, height = 4, 
#'        scale = 300, windowsize = c(1400, 866), zoom = 0.6, phi = 30, theta = 30)
#'render_snapshot()
#'}
#'
#'if(run_documentation()) {
#'#You can specify the color and height separately using the `ggobj_height()` argument.
#'ggvolcano_surface = volcano %>%
#'reshape2::melt() %>%
#'  ggplot() +
#'  geom_contour(aes(x=Var1,y=Var2,z=value),color="black") +
#'  geom_contour_filled(aes(x=Var1,y=Var2,z=value))+
#'  scale_x_continuous("X",expand = c(0,0)) +
#'  scale_y_continuous("Y",expand = c(0,0)) +
#'  coord_fixed() +
#'  theme(legend.position = "none")
#'
#'plot_gg(ggvolcano_surface, ggobj_height = ggvolcano, 
#'       multicore = TRUE, raytrace = TRUE, width = 7, height = 4,
#'       scale = 300, windowsize = c(1400, 866), zoom = 0.6, phi = 30, theta = 30)
#'render_snapshot()
#'}
#'#Here, we will create a 3D plot of the mtcars dataset. This automatically detects 
#'#that the user used the `color` aesthetic instead of the `fill`.
#'mtplot = ggplot(mtcars) + 
#'  geom_point(aes(x=mpg,y=disp,color=cyl)) + 
#'  scale_color_continuous(limits=c(0,8)) 
#'
#'#Preview how the plot will look by setting `preview = TRUE`: We also adjust the angle of the light.
#'if(run_documentation()) {
#'plot_gg(mtplot, width=3.5, sunangle=225, preview = TRUE)
#'}
#'if(run_documentation()) {
#'plot_gg(mtplot, width=3.5, multicore = TRUE, windowsize = c(1400,866), sunangle=225,
#'        zoom = 0.60, phi = 30, theta = 45)
#'render_snapshot()
#'}
#'#Now let's plot a density plot in 3D.
#'mtplot_density = ggplot(mtcars) + 
#'  stat_density_2d(aes(x=mpg,y=disp, fill=after_stat(!!str2lang("density"))), 
#'                  geom = "raster", contour = FALSE) +
#'  scale_x_continuous(expand=c(0,0)) +
#'  scale_y_continuous(expand=c(0,0)) +
#'  scale_fill_gradient(low="pink", high="red")
#'mtplot_density
#'
#'if(run_documentation()) {
#'plot_gg(mtplot_density, width = 4,zoom = 0.60, theta = -45, phi = 30, 
#'        windowsize = c(1400,866))
#'render_snapshot()
#'}
#'#This also works facetted.
#'mtplot_density_facet = mtplot_density + facet_wrap(~cyl) 
#'
#'#Preview this plot in 2D:
#'if(run_documentation()) {
#'plot_gg(mtplot_density_facet, preview = TRUE)
#'}
#'if(run_documentation()) {
#'plot_gg(mtplot_density_facet, windowsize=c(1400,866),
#'        zoom = 0.55, theta = -10, phi = 25)
#'render_snapshot()
#'}
#'#That is a little cramped. Specifying a larger width will improve the readability of this plot.
#'if(run_documentation()) {
#'plot_gg(mtplot_density_facet, width = 6, preview = TRUE)
#'}
#'
#'#That's better. Let's plot it in 3D, and increase the scale.
#'if(run_documentation()) {
#'plot_gg(mtplot_density_facet, width = 6, windowsize=c(1400,866),
#'        zoom = 0.55, theta = -10, phi = 25, scale=300)
#'render_snapshot()
#'}
#'
#'#We can also render a flat version of the plot alongside (or above/below) the 3D version.
#'if(run_documentation()) {
#'plot_gg(mtplot_density_facet, width = 6, windowsize=c(1400,866),
#'        zoom = 0.65, theta = -25, phi = 35, scale=300, flat_plot_render=TRUE,
#'        flat_direction = "x")
#'render_snapshot()
#'}
plot_gg = function(ggobj, ggobj_height = NULL, width = 3, height = 3, 
                   height_aes = NULL, invert = FALSE, shadow_intensity = 0.5,
                   units = c("in", "cm", "mm"), scale=150, pointcontract = 0.7, offset_edges = FALSE,
                   flat_plot_render = FALSE, flat_distance = "auto", 
                   flat_transparent_bg = FALSE, flat_direction = "-z",
                   shadow = TRUE, shadowdepth = "auto", shadowcolor = "auto", shadow_darkness = 0.5,
                   background = "white",
                   preview = FALSE, raytrace = TRUE, sunangle = 315, anglebreaks = seq(30,40,0.1), 
                   multicore = FALSE, lambert=TRUE, triangulate = TRUE,
                   max_error = 0.001, max_tri = 0, verbose= FALSE, emboss_text = 0, emboss_grid = 0,
                   reduce_size = NULL, save_height_matrix = FALSE, 
                   save_shadow_matrix = FALSE, saved_shadow_matrix=NULL,  ...) {
  if(!(length(find.package("ggplot2", quiet = TRUE)) > 0)) {
    stop("Must have ggplot2 installed to use plot_gg()")
  }
  heightmaptemp = tempfile(fileext = ".png")
  colormaptemp = tempfile(fileext = ".png")
  if(is.null(ggobj_height)) {
    if(methods::is(ggobj,"list") && length(ggobj) == 2) {
      stopifnot(inherits(ggobj[[2]], "ggplot"))
      stopifnot(inherits(ggobj[[1]], "ggplot"))
      ggplotobj2 = unserialize(serialize(ggobj[[2]], NULL))
      color_gg = unserialize(serialize(ggobj[[1]], NULL))
      ggplot2::ggsave(colormaptemp,ggobj[[1]],width = width,height = height,dpi=300)
    } else {
      stopifnot(inherits(ggobj, "ggplot"))
      ggplotobj2 = unserialize(serialize(ggobj, NULL))
      color_gg = unserialize(serialize(ggobj, NULL))
      ggplot2::ggsave(colormaptemp,ggplotobj2,width = width,height = height,dpi=300)
    }
  } else {
    stopifnot(inherits(ggobj, "ggplot"))
    stopifnot(inherits(ggobj_height, "ggplot"))
    ggplotobj2 = unserialize(serialize(ggobj_height, NULL))
    color_gg = unserialize(serialize(ggobj, NULL))
    ggplot2::ggsave(colormaptemp,color_gg,width = width,height = height,dpi=300)
  }
  
  set_to_white = function(grob) {
    if(!is.null(grob[["grobs"]])) {
      for(j in seq_len(length(grob$grobs))) {
        grob$grobs[[j]] = set_to_white(grob$grobs[[j]])
      }
    } else if (!is.null(grob[["children"]])) {
      for(j in seq_len(length(grob$children))) {
        grob$children[[j]] = set_to_white(grob$children[[j]])
      }
    } else if (length(grob) == 1 && inherits(grob[[1]],"gTree")) {
      grob[[1]] = set_to_white(grob[[1]])
    } else if(!(length(grep("geom", x = grob$name)) > 0) && !(length(grep("pathgrob", x = grob$name)) > 0)) {
      grob$gp$col = "white"
      grob$gp$alpha =0
      grob$gp$fill = "white"
      grob$gp$lwd = 0
      class(grob$gp) = "gpar"
    }
    return(grob)
  }
  emboss_gg_text = function(grob, emboss) {
    if(!is.null(grob[["grobs"]])) {
      for(j in seq_len(length(grob$grobs))) {
        grob$grobs[[j]] = emboss_gg_text(grob$grobs[[j]], emboss)
      }
    } else if (!is.null(grob[["children"]])) {
      for(j in seq_len(length(grob$children))) {
        grob$children[[j]] = emboss_gg_text(grob$children[[j]], emboss)
      }
    } else if(all(inherits(grob, c("text","grob"), which=TRUE)>0)) {
      emboss = ceiling(max(c(min(c(emboss,1)),0))*100)
      colval = ifelse(emboss != 100, sprintf("grey%d",emboss), "white")
      grob$gp$col = colval
      grob$gp$alpha = 1
      grob$gp$fill = colval
      class(grob$gp) = "gpar"
    }
    return(grob)
  }
  emboss_gg_grid = function(grob, emboss) {
    if(!is.null(grob[["grobs"]])) {
      for(j in seq_len(length(grob$grobs))) {
        grob$grobs[[j]] = emboss_gg_grid(grob$grobs[[j]], emboss)
      }
    } else if (!is.null(grob[["children"]])) {
      for(j in seq_len(length(grob$children))) {
        grob$children[[j]] = emboss_gg_grid(grob$children[[j]], emboss)
      }
    } else if((all(inherits(grob, c("polyline","grob"), which=TRUE)>0) && 
              length(grep("panel.grid", grob$name)) > 0) || 
              (all(inherits(grob, c("lines","grob"), which=TRUE)>0) && 
              (length(grep("GRID.lines", grob$name)) > 0)) ) {
      if(length(grep("GRID.lines", grob$name)) > 0) {
        emboss = emboss[1]
      }
      if(length(grep("panel.grid.major", grob$name)) > 0) {
        emboss = emboss[1]
      }
      if(length(grep("panel.grid.minor", grob$name)) > 0) {
        emboss = emboss[2]
      }
      emboss = ceiling(max(c(min(c(emboss,1)),0))*100)
      colval = ifelse(emboss != 100, sprintf("grey%d",emboss), "white")
      grob$gp$col = colval
      grob$gp$alpha = 1
      grob$gp$fill = colval
      grob$gp$lwd = 1
      class(grob$gp) = "gpar"
    }
    return(grob)
  }
  #Determine if auto fill or color aes to be mapped to 3D
  isfill = FALSE
  iscolor = FALSE
  if(is.null(height_aes)) {
    for(i in seq_len(length(ggplotobj2$layers))) {
      if("fill" %in% names(ggplotobj2$layers[[i]]$mapping)) {
        isfill = TRUE
      }
      if(any(c("color","colour") %in% names(ggplotobj2$layers[[i]]$mapping))) {
        iscolor = TRUE
      }
    }
    if(!iscolor && !isfill) {
      if("fill" %in% names(ggplotobj2$mapping)) {
        isfill = TRUE
      }
      if(any(c("color","colour") %in% names(ggplotobj2$mapping))) {
        iscolor = TRUE
      }
    }
    if(isfill && !iscolor) {
      height_aes = "fill"
    } else if (!isfill && iscolor) {
      height_aes = "colour"
    } else if (isfill && iscolor) {
      height_aes = "fill"
    } else {
      height_aes = "fill"
    }
  }
  if(height_aes == "color") {
    height_aes = "colour"
  }
  if(is.numeric(offset_edges)) {
    polygon_offset_value = offset_edges
    offset_edges = TRUE
  } else {
    polygon_offset_value = 0.5
  }
  polygon_offset_geoms = c("GeomPolygon","GeomSf", "GeomHex", "GeomTile")
  other_height_type = ifelse(height_aes == "colour", "fill", "colour")
  
  black_white_pal = function(x) {
    grDevices::colorRampPalette(c("white", "black"))(255)[x * 254 + 1]
  }
  white_white_pal = function(x) {
    grDevices::colorRampPalette(c("white", "white"))(255)[x * 254 + 1]
  }
  ifelsefxn = function(entry) {
    if(!is.null(entry)) {
      return(entry)
    }
  }
  
  #Shift all continuous palettes of height_aes to black/white, and set all discrete key colors to white.
  if(ggplotobj2$scales$n() != 0) {
    anyfound = FALSE
    #Check to see if same guide being used for both color and fill aesthetics
    if(ggplotobj2$scales$has_scale("colour") && ggplotobj2$scales$has_scale("fill")) {
      fillscale = ggplotobj2$scales$get_scales("fill")
      colorscale = ggplotobj2$scales$get_scales("colour")
      same_limits = FALSE
      same_breaks = FALSE
      same_labels = FALSE
      same_calls = FALSE
      if((!is.null(fillscale$limits) && !is.null(colorscale$limits))) {
        if(fillscale$limits == colorscale$limits) {
          same_limits = TRUE
        }
      } else if (is.null(fillscale$limits) && is.null(colorscale$limits)) {
        same_limits = TRUE
      }
      if((!is.null(fillscale$breaks) && !is.null(colorscale$breaks))) {
        if(all(fillscale$breaks == colorscale$breaks)) {
          same_breaks = TRUE
        }
      } else if (is.null(fillscale$breaks) && is.null(colorscale$breaks)) {
        same_breaks = TRUE
      }
      if(!inherits(fillscale$labels, "waiver") && !inherits(colorscale$labels, "waiver")) {
        if(all(fillscale$labels == colorscale$labels)) {
          same_labels = TRUE
        }
      } else if (inherits(fillscale$labels, "waiver") && inherits(colorscale$labels, "waiver")) {
        same_labels = TRUE
      }
      if(fillscale$call == colorscale$call) {
        same_calls = TRUE
      }
      if(same_limits && same_breaks && same_labels && same_calls) {
        if(height_aes == "fill") {
          ggplotobj2 = ggplotobj2 + ggplot2::guides(color = "none")
        } else {
          ggplotobj2 = ggplotobj2 + ggplot2::guides(fill = "none")
        }
      }
    }
    #Now check for scales and change to the b/w palette, but preserve guide traits.
    for(i in seq_len(ggplotobj2$scales$n())) {
      if(height_aes %in% ggplotobj2$scales$scales[[i]]$aesthetics) {
        ggplotobj2$scales$scales[[i]]$palette = black_white_pal
        ggplotobj2$scales$scales[[i]]$na.value = "white"
        has_guide = !any(inherits(ggplotobj2$scales$scales[[i]]$guide,"guide"))
        if(any(inherits(ggplotobj2$scales$scales[[i]]$guide,"logical"))) {
          has_guide = ggplotobj2$scales$scales[[i]]$guide
        }
        if(has_guide) {
          if(height_aes == "fill") {
            if(is.null(ggplotobj2$guides$fill)) {
              ggplotobj2 = ggplotobj2 + ggplot2::guides(fill = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000,order=i))
            } else {
              if(any(ggplotobj2$guides$fill != "none")) {
                copyguide = ggplotobj2$guides$fill
                copyguide$frame.linewidth = 0
                copyguide$legend.ticks = ggplot2::element_blank()
                copyguide$nbin = 1000
                ggplotobj2 = ggplotobj2 + 
                  ggplot2::guides(fill = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
                ggplotobj2$guides$fill = copyguide
              }
            }
            for(j in seq_len(length(ggplotobj2$layers))) {
              if("colour" %in% names(ggplotobj2$layers[[j]]$mapping)) {
                ggplotobj2$layers[[j]]$geom$draw_key = drawkeyfunction_points
              }
            }
          } else {
            if(is.null(ggplotobj2$guides$colour)) {
              ggplotobj2 = ggplotobj2 + ggplot2::guides(colour = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000,order=i))
            } else {
              if(any(ggplotobj2$guides$colour != "none")) {
                copyguide = ggplotobj2$guides$colour
                copyguide$frame.linewidth = 0
                copyguide$legend.ticks = ggplot2::element_blank()
                copyguide$nbin = 1000
                ggplotobj2 = ggplotobj2 + 
                  ggplot2::guides(colour = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
                ggplotobj2$guides$colour = copyguide
              }
            }
          }
        }
        anyfound = TRUE
      } else if(other_height_type %in% ggplotobj2$scales$scales[[i]]$aesthetics) {
        #change guides for other height_aes to be the all white palette
        ggplotobj2$scales$scales[[i]]$palette = white_white_pal
        ggplotobj2$scales$scales[[i]]$na.value = "white"
      } 
    }
    #If no scales found, just add one to the ggplot object.
    if(!anyfound) {
      if(height_aes == "colour") {
        ggplotobj2 = ggplotobj2 + 
          ggplot2::scale_color_gradientn(colours = grDevices::colorRampPalette(c("white","black"))(256), na.value = "white") +
          ggplot2::guides(colour = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
      }
      if(height_aes == "fill") {
        ggplotobj2 = ggplotobj2 + 
          ggplot2::scale_fill_gradientn(colours = grDevices::colorRampPalette(c("white","black"))(256), na.value = "white") +
          ggplot2::guides(fill = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
      }
    }
  } else {
    #If no scales found, just add one to the ggplot object.
    if(ggplotobj2$scales$n() == 0) {
      if(height_aes == "fill") {
        ggplotobj2 = ggplotobj2 + 
          ggplot2::scale_fill_gradientn(colours = grDevices::colorRampPalette(c("white","black"))(256), na.value = "white") +
          ggplot2::guides(fill = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
      } else {
        ggplotobj2 = ggplotobj2 + 
          ggplot2::scale_color_gradientn(colours = grDevices::colorRampPalette(c("white","black"))(256), na.value = "white") +
          ggplot2::guides(colour = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
      }
    } else {
      if(height_aes == "fill") {
        ggplotobj2 = ggplotobj2 + ggplot2::scale_fill_gradientn(colours = grDevices::colorRampPalette(c("white","black"))(256), na.value = "white") +
          ggplot2::guides(fill = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
      } else {
        ggplotobj2 = ggplotobj2 + ggplot2::scale_color_gradientn(colours = grDevices::colorRampPalette(c("white","black"))(256), na.value = "white") +
          ggplot2::guides(colour = ggplot2::guide_colourbar(legend.ticks = ggplot2::element_blank(),nbin = 1000))
      }
    }
  }
  if(height_aes == "fill") {
    for(layer in seq_along(1:length(ggplotobj2$layers))) {
      if("colour" %in% names(ggplotobj2$layers[[layer]]$mapping) || 
         0 == length(names(ggplotobj2$layers[[layer]]$mapping))) {
        ggplotobj2$layers[[layer]]$aes_params$colour = "white"
      }
      if("fill" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$aes_params$size = NA
        if(any(as.logical(inherits(ggplotobj2$layers[[layer]]$geom,polygon_offset_geoms))) && offset_edges) {
          ggplotobj2$layers[[layer]]$aes_params$size = polygon_offset_value
          ggplotobj2$layers[[layer]]$aes_params$colour = "white"
        }
      }
      if("shape" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        shapedata = ggplot2::layer_data(ggplotobj2)
        numbershapes = length(unique(shapedata$shape))
        if(numbershapes > 3) {
          warning("Non-solid shapes will not be projected to 3D.")
        }
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_points
      }
      if("size" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_points
      }
      if("alpha" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_points
        for(j in seq_len(length(ggplotobj2$layers))) {
          if("stroke" %in% names(ggplotobj2$layers[[j]]$geom$default_aes)) {
            ggplotobj2$layers[[j]]$geom$default_aes$stroke = 0
          }
        }
        ggplotobj2 = suppressMessages({ggplotobj2 + ggplot2::scale_alpha_continuous(range=c(1,1))})
      }
      if("linetype" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_lines
      }
    }
  } else {
    for(layer in seq_len(length(ggplotobj2$layers))) {
      if("fill" %in% names(ggplotobj2$layers[[layer]]$mapping) || 
         0 == length(names(ggplotobj2$layers[[layer]]$mapping))) {
        ggplotobj2$layers[[layer]]$aes_params$fill = "white"
      }
      if("shape" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        shapedata = ggplot2::layer_data(ggplotobj2)
        numbershapes = length(unique(shapedata$shape))
        if(numbershapes > 3) {
          warning("Non-solid shapes will not be projected to 3D.")
        }
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_points
      }
      if("size" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_points
      }
      if("alpha" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_points
        for(j in seq_len(length(ggplotobj2$layers))) {
          if("stroke" %in% names(ggplotobj2$layers[[j]]$geom$default_aes)) {
            ggplotobj2$layers[[j]]$geom$default_aes$stroke = 0
          }
        }
        ggplotobj2 = suppressMessages({ggplotobj2 + ggplot2::scale_alpha_continuous(range=c(1,1))})
      }
      if("linetype" %in% names(ggplotobj2$layers[[layer]]$mapping)) {
        ggplotobj2$layers[[layer]]$geom$draw_key = drawkeyfunction_lines
      }
    }
  }
  #Offset edges for polygons/Perform point contraction
  if(height_aes == "fill") {
    if(length(ggplotobj2$layers) > 0) {
      for(i in seq_along(1:length(ggplotobj2$layers))) {
        ggplotobj2$layers[[i]]$aes_params$size = NA
        if(any(as.logical(inherits(ggplotobj2$layers[[layer]]$geom,polygon_offset_geoms))) && offset_edges) {
          ggplotobj2$layers[[i]]$aes_params$size = polygon_offset_value
          ggplotobj2$layers[[i]]$aes_params$colour = "white"
        }
      }
    }
  } else {
    if(length(ggplotobj2$layers) > 0) {
      for(i in seq_along(1:length(ggplotobj2$layers))) {
        ggplotobj2$layers[[i]]$aes_params$fill = "white"
        if(inherits(ggplotobj2$layers[[i]]$geom,"GeomContour")) {
          ggplotobj2$layers[[i]]$aes_params$alpha = 0
        }
      }
      if(pointcontract != 1) {
        for(i in 1:length(ggplotobj2$layers)) {
          if(!is.null(ggplotobj2$layers[[i]]$aes_params$size)) {
            ggplotobj2$layers[[i]]$aes_params$size = ggplotobj2$layers[[i]]$aes_params$size * pointcontract
          } else {
            ggplotobj2$layers[[i]]$geom$default_aes$size = ggplotobj2$layers[[i]]$geom$default_aes$size * pointcontract
          }
        }
      }
    }
  }
  
  ggplotobj2 = set_to_white(ggplot2::ggplotGrob(ggplotobj2))
  if(emboss_text > 0) {
    emboss_text=1-emboss_text
    ggplotobj2 = emboss_gg_text(ggplotobj2, emboss_text)
  }
  if(emboss_grid > 0) {
    if(length(emboss_grid) == 1) {
      emboss_grid = c(emboss_grid,emboss_grid/2)
    }
    emboss_grid=1-emboss_grid
    ggplotobj2 = emboss_gg_grid(ggplotobj2, emboss_grid)
  }
  old_dev = grDevices::dev.cur()
  grDevices::png(filename = heightmaptemp, width = width, height = height, units = "in",res=300)
  grid::grid.draw(ggplotobj2)
  grDevices::dev.off()
  if (old_dev > 1) {
    grDevices::dev.set(old_dev)
  }
  if(!is.null(reduce_size)) {
    if(!(length(find.package("magick", quiet = TRUE)) > 0)) {
      stop("magick package required to use argument reduce_size")
    } else {
      if(length(reduce_size) == 1 && reduce_size < 1) {
        scale = scale * reduce_size
        image_info = magick::image_read(heightmaptemp) %>%
          magick::image_info() 
        magick::image_read(heightmaptemp) %>%
          magick::image_resize(paste0(image_info$width * reduce_size,"x",image_info$height * reduce_size)) %>%
          magick::image_write(heightmaptemp)
      } else if (length(reduce_size) == 2 && all(reduce_size < 1)) {
        scale = scale * reduce_size[1]
        image_info = magick::image_read(heightmaptemp) %>%
          magick::image_info() 
        magick::image_read(heightmaptemp) %>%
          magick::image_resize(paste0(image_info$width * reduce_size[1],"x",image_info$height * reduce_size[1])) %>%
          magick::image_write(heightmaptemp)
        magick::image_read(colormaptemp) %>%
          magick::image_resize(paste0(image_info$width * reduce_size[2],"x",image_info$height * reduce_size[2])) %>%
          magick::image_write(colormaptemp)
      }
    }
  }
  mapcolor = png::readPNG(colormaptemp)
  mapheight = png::readPNG(heightmaptemp)
  if(length(dim(mapheight)) == 3) {
    mapheight = mapheight[,,1]
  } 
  if(invert) {
    mapheight = 1 - mapheight
  }
  zscale = 1/scale
  
  if(shadowdepth == "auto") {
    if(min(mapheight,na.rm=TRUE) != max(mapheight,na.rm=TRUE)) {
      shadowdepth = -scale/5
    } else {
      max_dim = max(dim(mapheight))
      shadowdepth = -max_dim/25
    }
  } else {
    shadowdepth = shadowdepth/zscale
  }
  if(flat_distance == "auto") {
    if(flat_direction == "x" || flat_direction == "-x" || flat_direction == "y" || flat_direction == "-y") {
      flat_distance = 0.5
    } else {
      if(flat_direction == "z") {
        flat_distance = 3
      } else {
        flat_distance = -3
      }
    }
  } else {
    if(flat_direction == "-z") {
      flat_distance = -flat_distance
    } 
  }
  shadow_flat = flat_plot_render && shadow && flat_distance*scale < shadowdepth
  shadowdepth = ifelse(shadow_flat, flat_distance*scale + shadowdepth, shadowdepth)
  if(raytrace) {
    if(is.null(saved_shadow_matrix)) {
      raylayer = ray_shade(t(1-mapheight),maxsearch = 600,sunangle = sunangle,anglebreaks = anglebreaks,
                           zscale=1/scale,multicore = multicore,lambert = lambert, ...)
      if(!preview) {
        mapcolor %>%
          add_shadow(raylayer,shadow_intensity) %>%
          plot_3d((t(1-mapheight)),zscale=1/scale, triangulate = triangulate, 
                  max_error = max_error, max_tri = max_tri, verbose = verbose, shadow = shadow,
                  shadowdepth=shadowdepth/scale, background = background, shadowcolor = shadowcolor,  ... )
      } else {
        mapcolor %>%
          add_shadow(raylayer,shadow_intensity) %>%
          plot_map()
      }
    } else {
      raylayer = saved_shadow_matrix
      if(!preview) {
        mapcolor %>%
          add_shadow(raylayer,shadow_intensity) %>%
          plot_3d((t(1-mapheight)),zscale=1/scale, triangulate = triangulate,
                  max_error = max_error, max_tri = max_tri, verbose = verbose, shadow = shadow, 
                  shadowdepth=shadowdepth/scale, background = background, shadowcolor = shadowcolor, ... )
      } else {
        mapcolor %>%
          add_shadow(raylayer,shadow_intensity) %>%
          plot_map()
      }
    }
  } else {
    if(!preview) {
      plot_3d(mapcolor, (t(1-mapheight)), zscale=1/scale, triangulate = triangulate,
              max_error = max_error, max_tri = max_tri, verbose = verbose, shadow = shadow, 
              shadowdepth=shadowdepth/scale, background = background, shadowcolor = shadowcolor, ...)
    } else {
      plot_map(mapcolor)
    }
  }
  if(!preview && flat_plot_render) {
    if(flat_transparent_bg) {
      new_temp = tempfile(fileext = ".png")
      color_gg = color_gg + ggplot2::theme(plot.background = ggplot2::element_rect(fill=NA,color=NA))
      ggplot2::ggsave(new_temp,color_gg,width = width,height = height,dpi=300)
      colormaptemp = new_temp
    }
    mapcolor = png::readPNG(colormaptemp)
    horizontal_offset = c(0,0)
    shadowwidth = max(floor(min(dim((t(1-mapheight))))/10),5)
    if(flat_direction == "x" || flat_direction == "-x") {
      horizontal_offset = abs(c(width*300,0)*flat_distance + c(width*150,0) + c(shadowwidth*2,0))
      if(flat_direction == "-x") {
        horizontal_offset = -horizontal_offset
      } 
      flat_distance = 0
    } else if (flat_direction == "y" || flat_direction == "-y") {
      horizontal_offset = abs(c(0,height*300)*flat_distance + c(0,height*150) + c(0,shadowwidth*2))
      if(flat_direction == "y") {
        horizontal_offset = -horizontal_offset
      } 
      flat_distance = 0
    }

    render_floating_overlay(mapcolor, altitude = flat_distance, heightmap = (t(1-mapheight)),
                            zscale=1/scale, horizontal_offset = horizontal_offset)
    if(shadow && flat_direction %in% c("x", "-x", "y", "-y")) {
      if(shadowcolor == "auto") {
        shadowcolor = convert_color(darken_color(background, darken=shadow_darkness), as_hex = TRUE)
      }
      make_shadow((t(1-mapheight)), shadowdepth, shadowwidth, background, shadowcolor,
                  offset = horizontal_offset)
    }
  }
  if(save_shadow_matrix & !save_height_matrix) {
    return(raylayer)
  }
  if(!save_shadow_matrix & save_height_matrix) {
    return(1-t(mapheight))
  }
  if(save_shadow_matrix & save_height_matrix) {
    return(list(1-t(mapheight),raylayer))
  }
  
}
