:- use_module(library(pce)).
:-use_module(library(pce_style_item)).
:-pce_image_directory('./images').
resource(login,image,image('inicio.bmp')).


% Interfaz principal
:- new(VentanaE, dialog('Framework Sugerido')),
   new(Etiqueta, label(nombre, 'SISTEMA EXPERTO - SUGERENCIA DE FRAMEWORK')),
   new(Salir, button('SALIR', message(VentanaE, destroy))),
   new(Usuario, button('Solicitar Sugerencia', message(@prolog, usuario))),
   new(Figure, figure),
   new(Bitmap, bitmap(resource(login), @on)),

   send(Etiqueta, font, font(arial, bold, 20)),
   send(VentanaE, display, Etiqueta, point(50, 10)),
   send(Bitmap, name, 1),
   send(Figure, display, Bitmap),
   send(Figure, status, 1),
   send(VentanaE, display, Figure, point(25, 40)),
   send(VentanaE, display, Usuario, point(30, 430)),
   send(VentanaE, display, Salir, point(400, 430)),
   send(VentanaE, open).



% Interfaz para el usuario
usuario :-
   new(VentanaU, dialog('Solicitar Sugerencia')),
   new(Etiqueta, label(nombre, 'SUGERENCIA DE FRAMEWORK')),
   new(Salir, button('Regresar', message(VentanaU, destroy))),

   % Menú Tipo de Aplicación
   new(Tipo, menu('Tipo de Aplicación')),
   send_list(Tipo, append, ['web', 'mobile', 'desktop', '3D', 'charts', 'maps', 'game', 'data']),

   % Menú Enfoque
   new(Enfoque, menu('Enfoque')),
   send_list(Enfoque, append, ['Frontend', 'Backend', 'Fullstack']),

   % Menú Experiencia
   new(Experiencia, menu('Experiencia')),
   send_list(Experiencia, append, ['Poca', 'Moderada', 'Amplia']),

   % Menú Tamaño del Equipo
   new(Tam_Equipo, menu('Tamaño del Equipo')),
   send_list(Tam_Equipo, append, ['Pequeño', 'Mediano', 'Grande']),

   % Menú Plazo Estimado
   new(Plazo, menu('Plazo Estimado')),
   send_list(Plazo, append, ['Corto', 'Mediano', 'Largo']),

   % Menú Presupuesto Estimado
   new(Presupuesto, menu('Presupuesto Estimado')),
   send_list(Presupuesto, append, ['Bajo', 'Medio', 'Alto']),

   % Menú Lenguaje con filas de 5
   new(Lenguaje, menu('Lenguaje', choice)),
   send(Lenguaje, layout, vertical),  % Configura el layout vertical
   send(Lenguaje, columns, 5),        % Configura las columnas
   send_list(Lenguaje, append, [
       'JavaScript', 'TypeScript', 'Python', 'Java', 'Kotlin', 
       'PHP', 'C#', 'Dart', 'Swift', 'C++', 
       'Ruby', 'Elixir', 'Scala', 'GDScript', 'C', 
       'Go'
   ]),

   % Campo para la sugerencia
   new(Nombre, text_item('Framework Recomendado')),
   send(Nombre, editable, false),
   new(Jus,text_item('Justificacion')),
   send(Jus, editable, false),

   % Botón para solicitar sugerencia
   new(SugerenciaBtn, button('Solicitar Sugerencia',
       message(@prolog, framework, Tipo?selection, Enfoque?selection,
               Experiencia?selection, Tam_Equipo?selection,
               Presupuesto?selection, Plazo?selection, Lenguaje?selection, Nombre))),

    new(JustBtn, button('Solicitar Justificacion',message(@prolog,jframework,
                                                             Nombre?selection,
                                                             Jus))),

   % Configurar etiqueta
   send(Etiqueta, font, font(arial, bold, 20)),

   % Añadir componentes a la ventana
   send(VentanaU, append, Etiqueta),
   send(VentanaU, append, Tipo),
   send(VentanaU, append, Enfoque),
   send(VentanaU, append, Experiencia),
   send(VentanaU, append, Tam_Equipo),
   send(VentanaU, append, Plazo),
   send(VentanaU, append, Presupuesto),
   send(VentanaU, append, Lenguaje),
   send(VentanaU, append, SugerenciaBtn),
   send(VentanaU, append, Nombre),
   send(VentanaU,append,JustBtn),
   send(VentanaU,append,Jus),
   send(VentanaU, append, Salir),

   % Mostrar ventana
   send(VentanaU, open).

%------------------------------------------------------------------
%
%                    REGLA
%------------------------------------------------------------------

framework(Tipo, Enfoque, Experiencia, Tam_Equipo, Presupuesto, Plazo, Lenguaje, Nombre) :-
    % Verificar tipo y enfoque
    ( verificar_tipo(N, Tipo, Enfoque) ->
        true
    ; mostrar_error('Error: No se encontró un tipo o enfoque válido.'),
      fail
    ),
    % Verificar contexto
    ( verificar_contexto(N, Plazo, Presupuesto) ->
        true
    ; mostrar_error('Error: No se encontró coincidencia en el plazo o presupuesto.'),
        fail
        ),
    % Verificar personal
    ( verificar_personal(N, Experiencia, Tam_Equipo) ->
        true
    ; mostrar_error('Error: No se encontró coincidencia en la experiencia o tamaño de equipo.'),
      fail
    ),
    
    % Verificar lenguaje
    ( verificar_lenguaje(N, Lenguaje) ->
        true
    ; mostrar_error('Error: No se encontró coincidencia en el lenguaje.'),
      fail
    ),
    % Si todo es válido, mostrar el resultado en una ventana
    mostrar_resultado(Nombre, N),
    !.


% Mostrar resultado exitoso
mostrar_resultado(Nombre, N) :-
    new(VentanaU, dialog('Sugerencia de Framework')),
    format(atom(Mensaje), 'Framework sugerido: ~w', [N]),
    new(Lie2, label(texto, Mensaje, font('times', 'roman', 17))),
    send(Nombre, selection, N),  % Actualiza la selección en la interfaz
    send(VentanaU, append, Lie2),
    send(VentanaU, open).

% Mostrar mensaje de error
mostrar_error(Mensaje) :-
    new(VentanaE, dialog('Error')),
    new(Lie, label(texto, Mensaje, font('times', 'roman', 17))),
    send(VentanaE, append, Lie),
    send(VentanaE, open).




% Verificar tipo y enfoque
verificar_tipo(N, Tipo, Enfoque) :-
    tipo(N, Tipo, Enfoque), !.  % Si se cumple, continúa
verificar_tipo(_, _, _) :-
    write('Error: No se encontró un tipo o enfoque válido.'), nl,
    fail.

% Verificar personal
verificar_personal(N, Experiencia, Tam_Equipo) :-
    personal(N, Experiencia, Tam_Equipo), !.  % Si se cumple, continúa
verificar_personal(_, _, _) :-
    write('Error: No se encontró coincidencia en la experiencia o tamaño de equipo.'), nl,
    fail.

% Verificar contexto
verificar_contexto(N, Plazo, Presupuesto) :-
    contexto(N, Plazo, Presupuesto), !.  % Si se cumple, continúa
verificar_contexto(_, _, _) :-
    write('Error: No se encontró coincidencia en el plazo o presupuesto.'), nl,
    fail.

% Verificar lenguaje
verificar_lenguaje(N, Lenguaje) :-
    lenguaje(N, Lenguaje), !.  % Si se cumple, continúa
verificar_lenguaje(_, _) :-
    write('Error: No se encontró coincidencia en el lenguaje.'), nl,
    fail.




jframework(Nombre,Sug):- 
                   justificacion(Nombre,Sugerencia),
                   send(Sug,selection,Sugerencia).


%------------------------------------------------------------------
%
%                    Base de Conocimiento
%
%------------------------------------------------------------------

%tipo(framework,tipo,enfoque)
:-dynamic tipo/3.
tipo('React','web','Frontend').
tipo('Angular','web','Frontend').
tipo('Vue','web','Frontend').
tipo('Django','web','Backend').
tipo('Flask','web','Backend').
tipo('Spring','web','Backend').
tipo('Express','web','Backend').
tipo('Laravel','web','Backend').
tipo('ASP.NET','web','Backend').
tipo('Flutter','mobile','Frontend').
tipo('React Native','mobile','Frontend').
tipo('SwiftUI','mobile','Frontend').
tipo('Kotlin Multiplatform','mobile','Frontend').
tipo('Electron','desktop','Frontend').
tipo('Qt','desktop','Frontend').
tipo('Tkinter','desktop','Frontend').
tipo('Next.js','web','Fullstack').
tipo('Nuxt.js','web','Fullstack').
tipo('Ruby on Rails','web','Fullstack').
tipo('Meteor','web','Fullstack').
tipo('Svelte','web','Frontend').
tipo('Blazor','web','Frontend').
tipo('Backbone.js','web','Frontend').
tipo('Ember.js','web','Frontend').
tipo('Phoenix','web','Backend').
tipo('FastAPI','web','Backend').
tipo('Gatsby','web','Frontend').
tipo('Gridsome','web','Frontend').
tipo('Capacitor','mobile','Frontend').
tipo('Ionic','mobile','Frontend').
tipo('Xamarin','mobile','Frontend').
tipo('PyQt','desktop','Frontend').
tipo('GTK','desktop','Frontend').
tipo('Unity','game','Frontend').
tipo('Unreal Engine','game','Frontend').
tipo('Godot','game','Frontend').
tipo('Pandas','data','Backend').
tipo('NumPy','data','Backend').
tipo('TensorFlow','data','Backend').
tipo('PyTorch','data','Backend').
tipo('Hadoop','data','Backend').
tipo('Spark','data','Backend').
tipo('Keras','data','Backend').
tipo('OpenCV','vision','Backend').
tipo('Three.js','3D','Frontend').
tipo('Babylon.js','3D','Frontend').
tipo('WebGL','3D','Frontend').
tipo('Cesium','3D','Frontend').
tipo('Leaflet','maps','Frontend').
tipo('Mapbox','maps','Frontend').
tipo('Plotly','charts','Frontend').
tipo('Chart.js','charts','Frontend').
tipo('D3.js','charts','Frontend').

% personal(framework, experiencia, tamaño_equipo)
:-dynamic personal/3.
personal('React', 'Poca', 'Pequeño').
personal('React', 'Moderada', 'Mediano').
personal('React', 'Amplia', 'Grande').
personal('Angular', 'Poca', 'Pequeño').
personal('Angular', 'Moderada', 'Mediano').
personal('Angular', 'Amplia', 'Grande').
personal('Vue', 'Poca', 'Pequeño').
personal('Vue', 'Moderada', 'Mediano').
personal('Vue', 'Amplia', 'Grande').
personal('Django', 'Poca', 'Pequeño').
personal('Django', 'Moderada', 'Mediano').
personal('Django', 'Amplia', 'Grande').
personal('Flask', 'Poca', 'Pequeño').
personal('Flask', 'Moderada', 'Mediano').
personal('Flask', 'Amplia', 'Grande').
personal('Spring', 'Poca', 'Pequeño').
personal('Spring', 'Moderada', 'Mediano').
personal('Spring', 'Amplia', 'Grande').
personal('Express', 'Poca', 'Pequeño').
personal('Express', 'Moderada', 'Mediano').
personal('Express', 'Amplia', 'Grande').
personal('Laravel', 'Poca', 'Pequeño').
personal('Laravel', 'Moderada', 'Mediano').
personal('Laravel', 'Amplia', 'Grande').
personal('ASP.NET', 'Poca', 'Pequeño').
personal('ASP.NET', 'Moderada', 'Mediano').
personal('ASP.NET', 'Amplia', 'Grande').
personal('Flutter', 'Poca', 'Pequeño').
personal('Flutter', 'Moderada', 'Mediano').
personal('Flutter', 'Amplia', 'Grande').
personal('React Native', 'Poca', 'Pequeño').
personal('React Native', 'Moderada', 'Mediano').
personal('React Native', 'Amplia', 'Grande').
personal('SwiftUI', 'Poca', 'Pequeño').
personal('SwiftUI', 'Moderada', 'Mediano').
personal('SwiftUI', 'Amplia', 'Grande').
personal('Kotlin Multiplatform', 'Poca', 'Pequeño').
personal('Kotlin Multiplatform', 'Moderada', 'Mediano').
personal('Kotlin Multiplatform', 'Amplia', 'Grande').
personal('Electron', 'Poca', 'Pequeño').
personal('Electron', 'Moderada', 'Mediano').
personal('Electron', 'Amplia', 'Grande').
personal('Qt', 'Poca', 'Pequeño').
personal('Qt', 'Moderada', 'Mediano').
personal('Qt', 'Amplia', 'Grande').
personal('Tkinter', 'Poca', 'Pequeño').
personal('Tkinter', 'Moderada', 'Mediano').
personal('Tkinter', 'Amplia', 'Grande').
personal('Next.js', 'Poca', 'Pequeño').
personal('Next.js', 'Moderada', 'Mediano').
personal('Next.js', 'Amplia', 'Grande').
personal('Nuxt.js', 'Poca', 'Pequeño').
personal('Nuxt.js', 'Moderada', 'Mediano').
personal('Nuxt.js', 'Amplia', 'Grande').
personal('Ruby on Rails', 'Poca', 'Pequeño').
personal('Ruby on Rails', 'Moderada', 'Mediano').
personal('Ruby on Rails', 'Amplia', 'Grande').
personal('Meteor', 'Poca', 'Pequeño').
personal('Meteor', 'Moderada', 'Mediano').
personal('Meteor', 'Amplia', 'Grande').
personal('Svelte', 'Poca', 'Pequeño').
personal('Svelte', 'Moderada', 'Mediano').
personal('Svelte', 'Amplia', 'Grande').
personal('Blazor', 'Poca', 'Pequeño').
personal('Blazor', 'Moderada', 'Mediano').
personal('Blazor', 'Amplia', 'Grande').
personal('Backbone.js', 'Poca', 'Pequeño').
personal('Backbone.js', 'Moderada', 'Mediano').
personal('Backbone.js', 'Amplia', 'Grande').
personal('Ember.js', 'Poca', 'Pequeño').
personal('Ember.js', 'Moderada', 'Mediano').
personal('Ember.js', 'Amplia', 'Grande').
personal('Phoenix', 'Poca', 'Pequeño').
personal('Phoenix', 'Moderada', 'Mediano').
personal('Phoenix', 'Amplia', 'Grande').
personal('FastAPI', 'Poca', 'Pequeño').
personal('FastAPI', 'Moderada', 'Mediano').
personal('FastAPI', 'Amplia', 'Grande').
personal('Gatsby', 'Poca', 'Pequeño').
personal('Gatsby', 'Moderada', 'Mediano').
personal('Gatsby', 'Amplia', 'Grande').
personal('Gridsome', 'Poca', 'Pequeño').
personal('Gridsome', 'Moderada', 'Mediano').
personal('Gridsome', 'Amplia', 'Grande').
personal('Capacitor', 'Poca', 'Pequeño').
personal('Capacitor', 'Moderada', 'Mediano').
personal('Capacitor', 'Amplia', 'Grande').
personal('Ionic', 'Poca', 'Pequeño').
personal('Ionic', 'Moderada', 'Mediano').
personal('Ionic', 'Amplia', 'Grande').
personal('Xamarin', 'Poca', 'Pequeño').
personal('Xamarin', 'Moderada', 'Mediano').
personal('Xamarin', 'Amplia', 'Grande').
personal('PyQt', 'Poca', 'Pequeño').
personal('PyQt', 'Moderada', 'Mediano').
personal('PyQt', 'Amplia', 'Grande').
personal('GTK', 'Poca', 'Pequeño').
personal('GTK', 'Moderada', 'Mediano').
personal('GTK', 'Amplia', 'Grande').
personal('Unity', 'Poca', 'Pequeño').
personal('Unity', 'Moderada', 'Mediano').
personal('Unity', 'Amplia', 'Grande').
personal('Unreal Engine', 'Poca', 'Pequeño').
personal('Unreal Engine', 'Moderada', 'Mediano').
personal('Unreal Engine', 'Amplia', 'Grande').
personal('Godot', 'Poca', 'Pequeño').
personal('Godot', 'Moderada', 'Mediano').
personal('Godot', 'Amplia', 'Grande').
personal('Pandas', 'Poca', 'Pequeño').
personal('Pandas', 'Moderada', 'Mediano').
personal('Pandas', 'Amplia', 'Grande').
personal('NumPy', 'Poca', 'Pequeño').
personal('NumPy', 'Moderada', 'Mediano').
personal('NumPy', 'Amplia', 'Grande').
personal('TensorFlow', 'Poca', 'Pequeño').
personal('TensorFlow', 'Moderada', 'Mediano').
personal('TensorFlow', 'Amplia', 'Grande').
personal('PyTorch', 'Poca', 'Pequeño').
personal('PyTorch', 'Moderada', 'Mediano').
personal('PyTorch', 'Amplia', 'Grande').
personal('Hadoop', 'Poca', 'Pequeño').
personal('Hadoop', 'Moderada', 'Mediano').
personal('Hadoop', 'Amplia', 'Grande').
personal('Spark', 'Poca', 'Pequeño').
personal('Spark', 'Moderada', 'Mediano').
personal('Spark', 'Amplia', 'Grande').
personal('Keras', 'Poca', 'Pequeño').
personal('Keras', 'Moderada', 'Mediano').
personal('Keras', 'Amplia', 'Grande').
personal('OpenCV', 'Poca', 'Pequeño').
personal('OpenCV', 'Moderada', 'Mediano').
personal('OpenCV', 'Amplia', 'Grande').
personal('Three.js', 'Poca', 'Pequeño').
personal('Three.js', 'Moderada', 'Mediano').
personal('Three.js', 'Amplia', 'Grande').
personal('Babylon.js', 'Poca', 'Pequeño').
personal('Babylon.js', 'Moderada', 'Mediano').
personal('Babylon.js', 'Amplia', 'Grande').
personal('WebGL', 'Poca', 'Pequeño').
personal('WebGL', 'Moderada', 'Mediano').
personal('WebGL', 'Amplia', 'Grande').
personal('Cesium', 'Poca', 'Pequeño').
personal('Cesium', 'Moderada', 'Mediano').
personal('Cesium', 'Amplia', 'Grande').
personal('Leaflet', 'Poca', 'Pequeño').
personal('Leaflet', 'Moderada', 'Mediano').
personal('Leaflet', 'Amplia', 'Grande').
personal('Mapbox', 'Poca', 'Pequeño').
personal('Mapbox', 'Moderada', 'Mediano').
personal('Mapbox', 'Amplia', 'Grande').
personal('Plotly', 'Poca', 'Pequeño').
personal('Plotly', 'Moderada', 'Mediano').
personal('Plotly', 'Amplia', 'Grande').
personal('Chart.js', 'Poca', 'Pequeño').
personal('Chart.js', 'Moderada', 'Mediano').
personal('Chart.js', 'Amplia', 'Grande').


% contexto(framework, plazo_de_tiempo, presupuesto)
:-dynamic contexto/3.
contexto('React', 'Corto', 'Bajo').
contexto('React', 'Corto', 'Medio').
contexto('React', 'Mediano', 'Medio').
contexto('Angular', 'Mediano', 'Medio').
contexto('Angular', 'Mediano', 'Alto').
contexto('Vue', 'Corto', 'Bajo').
contexto('Vue', 'Mediano', 'Medio').
contexto('Django', 'Largo', 'Alto').
contexto('Django', 'Mediano', 'Medio').
contexto('Flask', 'Corto', 'Bajo').
contexto('Flask', 'Corto', 'Medio').
contexto('Spring', 'Largo', 'Alto').
contexto('Spring', 'Mediano', 'Medio').
contexto('Express', 'Mediano', 'Medio').
contexto('Express', 'Corto', 'Bajo').
contexto('Laravel', 'Mediano', 'Medio').
contexto('Laravel', 'Largo', 'Medio').
contexto('ASP.NET', 'Largo', 'Alto').
contexto('ASP.NET', 'Mediano', 'Medio').
contexto('Flutter', 'Corto', 'Bajo').
contexto('Flutter', 'Mediano', 'Medio').
contexto('React Native', 'Mediano', 'Medio').
contexto('React Native', 'Corto', 'Medio').
contexto('SwiftUI', 'Mediano', 'Medio').
contexto('SwiftUI', 'Mediano', 'Alto').
contexto('Kotlin Multiplatform', 'Largo', 'Alto').
contexto('Electron', 'Corto', 'Bajo').
contexto('Electron', 'Corto', 'Medio').
contexto('Qt', 'Mediano', 'Medio').
contexto('Qt', 'Mediano', 'Alto').
contexto('Tkinter', 'Corto', 'Bajo').
contexto('Tkinter', 'Corto', 'Medio').
contexto('Next.js', 'Mediano', 'Medio').
contexto('Nuxt.js', 'Mediano', 'Medio').
contexto('Ruby on Rails', 'Largo', 'Alto').
contexto('Spark', 'Largo', 'Alto').
contexto('Hadoop', 'Largo', 'Alto').
contexto('Keras', 'Mediano', 'Medio').
contexto('OpenCV', 'Mediano', 'Alto').
contexto('Three.js', 'Corto', 'Bajo').
contexto('Three.js', 'Corto', 'Medio').
contexto('Babylon.js', 'Corto', 'Bajo').
contexto('Babylon.js', 'Corto', 'Medio').
contexto('WebGL', 'Corto', 'Bajo').
contexto('WebGL', 'Corto', 'Medio').
contexto('Cesium', 'Mediano', 'Medio').
contexto('Leaflet', 'Corto', 'Bajo').
contexto('Leaflet', 'Corto', 'Medio').
contexto('Mapbox', 'Mediano', 'Medio').
contexto('Plotly', 'Mediano', 'Medio').
contexto('Chart.js', 'Corto', 'Bajo').
contexto('Chart.js', 'Corto', 'Medio').
contexto('D3.js', 'Corto', 'Bajo').
contexto('D3.js', 'Corto', 'Medio').
contexto('Ruby on Rails', 'Mediano', 'Alto').
contexto('Meteor', 'Mediano', 'Medio').
contexto('Svelte', 'Corto', 'Bajo').
contexto('Svelte', 'Corto', 'Medio').
contexto('Blazor', 'Mediano', 'Medio').
contexto('Phoenix', 'Largo', 'Alto').
contexto('FastAPI', 'Mediano', 'Medio').
contexto('FastAPI', 'Corto', 'Medio').
contexto('Unity', 'Mediano', 'Medio').
contexto('Unreal Engine', 'Largo', 'Alto').
contexto('Godot', 'Corto', 'Bajo').
contexto('Godot', 'Corto', 'Medio').
contexto('TensorFlow', 'Largo', 'Alto').
contexto('TensorFlow', 'Mediano', 'Alto').
contexto('PyTorch', 'Largo', 'Alto').
contexto('PyTorch', 'Mediano', 'Alto').


%lenguaje(framework,lenguaje)
:-dynamic lenguaje/2.
lenguaje('React','JavaScript').
lenguaje('React','TypeScript').
lenguaje('Angular','JavaScript').
lenguaje('Angular','TypeScript').
lenguaje('Vue','JavaScript').
lenguaje('Vue','TypeScript').
lenguaje('Django','Python').
lenguaje('Flask','Python').
lenguaje('Spring','Java').
lenguaje('Spring','Kotlin').
lenguaje('Express','JavaScript').
lenguaje('Express','TypeScript').
lenguaje('Laravel','PHP').
lenguaje('ASP.NET','C#').
lenguaje('Flutter','Dart').
lenguaje('React Native','JavaScript').
lenguaje('React Native','TypeScript').
lenguaje('SwiftUI','Swift').
lenguaje('Kotlin Multiplatform','Kotlin').
lenguaje('Electron','JavaScript').
lenguaje('Electron','TypeScript').
lenguaje('Qt','C++').
lenguaje('Qt','Python').
lenguaje('Tkinter','Python').
lenguaje('Next.js','JavaScript').
lenguaje('Next.js','TypeScript').
lenguaje('Nuxt.js','JavaScript').
lenguaje('Nuxt.js','TypeScript').
lenguaje('Ruby on Rails','Ruby').
lenguaje('Meteor','JavaScript').
lenguaje('Meteor','TypeScript').
lenguaje('Svelte','JavaScript').
lenguaje('Svelte','TypeScript').
lenguaje('Blazor','C#').
lenguaje('Backbone.js','JavaScript').
lenguaje('Backbone.js','TypeScript').
lenguaje('Ember.js','JavaScript').
lenguaje('Ember.js','TypeScript').
lenguaje('Phoenix','Elixir').
lenguaje('FastAPI','Python').
lenguaje('Gatsby','JavaScript').
lenguaje('Gatsby','TypeScript').
lenguaje('Gridsome','JavaScript').
lenguaje('Gridsome','TypeScript').
lenguaje('Capacitor','JavaScript').
lenguaje('Capacitor','TypeScript').
lenguaje('Ionic','JavaScript').
lenguaje('Ionic','TypeScript').
lenguaje('Xamarin','C#').
lenguaje('PyQt','Python').
lenguaje('GTK','C').
lenguaje('Unity','C#').
lenguaje('Unreal Engine','C++').
lenguaje('Godot','GDScript').
lenguaje('Godot','C#').
lenguaje('Pandas','Python').
lenguaje('NumPy','Python').
lenguaje('TensorFlow','Python').
lenguaje('TensorFlow','C++').
lenguaje('PyTorch','Python').
lenguaje('PyTorch','C++').
lenguaje('Hadoop','Java').
lenguaje('Spark','Scala').
lenguaje('Keras','Python').
lenguaje('OpenCV','Python').
lenguaje('OpenCV','C++').
lenguaje('Three.js','JavaScript').
lenguaje('Three.js','TypeScript').
lenguaje('Babylon.js','JavaScript').
lenguaje('Babylon.js','TypeScript').
lenguaje('WebGL','JavaScript').
lenguaje('WebGL','TypeScript').
lenguaje('Cesium','JavaScript').
lenguaje('Cesium','TypeScript').
lenguaje('Leaflet','JavaScript').
lenguaje('Leaflet','TypeScript').
lenguaje('Mapbox','JavaScript').
lenguaje('Mapbox','TypeScript').
lenguaje('Plotly','Python').
lenguaje('Plotly','JavaScript').
lenguaje('Chart.js','JavaScript').
lenguaje('Chart.js','TypeScript').
lenguaje('D3.js','JavaScript').
lenguaje('D3.js','TypeScript').

%justificacion(framework,justificacion)
:-dynamic justificacion/2.
justificacion('React','React es una biblioteca de JavaScript rápida y flexible que permite construir interfaces de usuario reutilizables con un alto rendimiento gracias a su Virtual DOM.').
justificacion('Angular','Angular es un framework completo que permite desarrollar aplicaciones web robustas con TypeScript, ideal para proyectos empresariales con arquitecturas complejas.').
justificacion('Vue','Vue es un framework progresivo que combina facilidad de aprendizaje con un enfoque modular, ideal para proyectos pequeños y medianos.').
justificacion('Django','Django es un framework web de alto nivel para Python que promueve el desarrollo rápido y limpio, con seguridad y escalabilidad integradas.').
justificacion('Flask','Flask es un microframework ligero y flexible para Python, ideal para proyectos pequeños o MVPs debido a su simplicidad.').
justificacion('Spring','Spring Framework es una poderosa herramienta de desarrollo backend para Java, ofreciendo un ecosistema robusto y extensible para aplicaciones empresariales.').
justificacion('Express','Express es un framework minimalista para Node.js que facilita el desarrollo rápido de aplicaciones web y APIs.').
justificacion('Laravel','Laravel es un framework PHP elegante y expresivo que simplifica tareas comunes como el manejo de bases de datos y autenticación.').
justificacion('ASP.NET','ASP.NET es un framework versátil de Microsoft que permite construir aplicaciones web y APIs altamente escalables en C#.').
justificacion('Flutter','Flutter permite desarrollar aplicaciones móviles con una sola base de código en Dart, ofreciendo una experiencia nativa en múltiples plataformas.').
justificacion('React Native','React Native permite crear aplicaciones móviles multiplataforma utilizando JavaScript, con componentes reutilizables y rendimiento casi nativo.').
justificacion('SwiftUI','SwiftUI es el framework moderno de Apple para construir interfaces de usuario declarativas en iOS, macOS y más.').
justificacion('Kotlin Multiplatform','Kotlin Multiplatform facilita el desarrollo de aplicaciones móviles compartiendo lógica de negocio entre plataformas, mientras usa código nativo para interfaces.').
justificacion('Electron','Electron permite crear aplicaciones de escritorio multiplataforma utilizando tecnologías web como HTML, CSS y JavaScript.').
justificacion('Qt','Qt es un framework potente para C++ que soporta el desarrollo de aplicaciones de escritorio multiplataforma con interfaces gráficas avanzadas.').
justificacion('Tkinter','Tkinter es la biblioteca estándar para interfaces gráficas en Python, ideal para prototipos o aplicaciones simples.').
justificacion('Next.js','Next.js es un framework React que simplifica el desarrollo de aplicaciones web server-side rendering (SSR) y estáticas.').
justificacion('Nuxt.js','Nuxt.js es un framework basado en Vue para aplicaciones server-side rendering (SSR) o estáticas, optimizado para SEO y rendimiento.').
justificacion('Ruby on Rails','Ruby on Rails es un framework fullstack que sigue el principio de convención sobre configuración, acelerando el desarrollo de aplicaciones web.').
justificacion('Meteor','Meteor es un framework fullstack para JavaScript que permite crear aplicaciones web y móviles con integración en tiempo real.').
justificacion('Svelte','Svelte es un framework innovador que convierte componentes en código optimizado, eliminando la necesidad de un Virtual DOM.').
justificacion('Blazor','Blazor es un framework de Microsoft para crear aplicaciones web interactivas utilizando C# y .NET en lugar de JavaScript.').
justificacion('Phoenix','Phoenix es un framework Elixir que aprovecha el modelo de concurrencia de Erlang para crear aplicaciones web escalables y en tiempo real.').
justificacion('FastAPI','FastAPI es un framework para Python diseñado para construir APIs modernas, rápidas y con validación automática de datos.').
justificacion('Unity','Unity es un motor de desarrollo de videojuegos con capacidades frontend para crear experiencias interactivas en 2D y 3D.').
justificacion('Unreal Engine','Unreal Engine es un potente motor gráfico utilizado para juegos y simulaciones, con herramientas avanzadas para renderizado.').
justificacion('Godot','Godot es un motor de videojuegos accesible y ligero que permite desarrollar experiencias en 2D y 3D con flexibilidad.').
justificacion('TensorFlow','TensorFlow es un framework de aprendizaje automático robusto, ideal para modelos complejos y despliegue escalable.').
justificacion('PyTorch','PyTorch es un framework flexible y dinámico para aprendizaje automático, ampliamente utilizado en investigación y desarrollo.').
