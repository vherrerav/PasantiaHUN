*********************************************************************************************************************
*** Tabla de conteo de servicios por paciente (identificaión y tipo de documento) y por año
*** Javier Amaya 
*** Fecha: 17/01/2020
*********************************************************************************************************************




use "C:\Users\gbuit\Dropbox\HUN\Estandares clinicos\BD_HUN.dta", clear

//Quitando observaciones que son incorrectas de toda la bd
drop if VALOR_TOTAL==0
drop if VALOR_TOTAL==.
 			
			//Verificacion de # observaciones sin y con collapse por ingreso-identificación
			//Observaciones sin agregar nada 3.878 millones de observaciones
			//Observaciones con collapse por identificación-ingreso = 208 mil 
				//se decide primero codificar los servicios de atención antes de colapsar
				
// Sacando las variables de conteo según categorias: Ambulatorio, Hospitalizacion,Procedimientos_qx,Imágenes diagnósticas,Laboratorios y otras puebas diagnósticas,Medicamentos,otros servicios


gen cups4d=CODIGO_SERVICIO
recast str4 cups4d, force

gen cups3d=CODIGO_SERVICIO
recast str3 cups3d, force

gen cups2d=CODIGO_SERVICIO
recast str2 cups2d, force

gen cups1d=CODIGO_SERVICIO
recast str1 cups1d, force


	//Ambulatorio
	gen ambula=1 if cups4d=="8901" | cups4d=="8902"| cups4d=="8903"| cups4d=="8904"| cups4d=="8905"
	replace ambula=0 if ambula==.
	
	//Hospitalizacion
	gen hx=1 if cups2d=="S1" | cups2d=="S2"
	replace hx=0 if hx==.
		
	
	//Procedimientos_qx
	gen procedimientos_qx=1 if cups2d=="01"| cups2d=="02"| cups2d=="03"| cups2d=="04"| cups2d=="05"| cups2d=="06"| cups2d=="07"| cups2d=="08"| cups2d=="09"| cups2d=="10"| cups2d=="11"| cups2d=="12"| cups2d=="13"| cups2d=="14"| cups2d=="15"| cups2d=="16"|cups2d=="17"| cups2d=="18"| cups2d=="19"| cups2d=="20"| cups2d=="21"| cups2d=="22"| cups2d=="23"| cups2d=="24"| cups2d=="25"| cups2d=="26"| cups2d=="27"| cups2d=="28"| cups2d=="29"| cups2d=="30"| cups2d=="31"| cups2d=="32"| cups2d=="33"| cups2d=="34"| cups2d=="35"| cups2d=="36"| cups2d=="37"| cups2d=="38"| cups2d=="39"| cups2d=="40"| cups2d=="41"| cups2d=="42"| cups2d=="43"| cups2d=="44"| cups2d=="45"| cups2d=="46"| cups2d=="47"| cups2d=="48"| cups2d=="49"| cups2d=="50"| cups2d=="51"| cups2d=="52"| cups2d=="53"| cups2d=="54"| cups2d=="55"| cups2d=="56"| cups2d=="57"| cups2d=="58"| cups2d=="59"| cups2d=="60"| cups2d=="61"| cups2d=="62"| cups2d=="63"| cups2d=="64"| cups2d=="65"| cups2d=="66"| cups2d=="67"| cups2d=="68"| cups2d=="69"| cups2d=="70"| cups2d=="71"| cups2d=="72"| cups2d=="73"| cups2d=="74"| cups2d=="75"| cups2d=="76"| cups2d=="77"| cups2d=="78"| cups2d=="79"| cups2d=="80"| cups2d=="81"| cups2d=="82"| cups2d=="83"| cups2d=="84"| cups2d=="85"| cups2d=="86"
	replace procedimientos_qx=0 if procedimientos_qx==.
	
	//Imagenes_dx
	** Todos los CUPS con raíz 87 y 88 son imágenes diagnósticas

	gen Imagenes_dx=1 	if cups2d=="87" | cups2d=="88" 
	replace Imagenes_dx=0 if Imagenes_dx==.
	
	
	
	
	//Laboratorios y otras pruebas dx
	** Todos los CUPS con raíz 90 son laboratorio clínico
	** Todos los CUPS con raíz 891-898 son otras pruebas diagnósticas
	gen Laboratorios=1 	if cups2d=="90"| cups3d=="891"| cups3d=="892"| cups3d=="893"| cups3d=="894"| cups3d=="895"| cups3d=="896"| cups3d=="897"| cups3d=="898"
	replace Laboratorios=0 if Laboratorios==.

	//Medicamentos
	gen Medicamentos=1  if cups1d=="A"|cups1d== "B"|cups1d== "C"|cups1d== "D"|cups1d== "E"|cups1d== "F"|cups1d== "G"|cups1d== "H"|cups1d== "I"|cups1d== "J"|cups1d== "K"|cups1d== "L"|cups1d== "M"|cups1d== "N"|cups1d== "O"|cups1d== "P"|cups1d== "Q"| cups1d== "R"|cups1d== "T"|cups1d== "V"|cups1d== "W"|cups1d== "X"|cups1d== "Y"|cups1d== "Z"|	cups2d== "S0" |cups2d== "S4"|cups2d== "S5"|cups2d== "SJ"|cups2d== "SM"|cups2d== "SR"|cups2d== "ST"|cups2d== "S3"|cups2d== "SS"
	replace Medicamentos=0 if Medicamentos==.
	
	
	//Otros_servicios 
	
	gen Otros_servicios=1 if cups2d== "93"| cups2d== "91"| cups2d== "94"| cups2d== "92"| cups2d== "95"| cups2d== "96"| cups2d== "97"| cups2d== "98"| cups2d== "99"| cups2d== "0S"| cups4d== "8906"| cups4d== "8907"
	replace Otros_servicios=0 if Otros_servicios==.
	
	
	//==Verificacion de coincidencia de valores 
	//drop if ambula==1| hx==1| procedimientos_qx==1| Imagenes_dx==1| Laboratorios==1| Medicamentos==1| Otros_servicios==1
	// no queda ninguna obervación, por lo que se peude decir que todo quedó clasificado en alguna categoria de atencion

// Generando la variable year para poder agregar por esta también 
gen fe_egr=dofc( FECHA_EGRESO )
format fe_egr %td
gen year=year(fe_egr)

	//==Verificacion de atenciones por año
	//tab year
	// el total de la sumatoria de las dos categorías es el mismo de las obervaciones 

// Agregando por tipo de documento e identificación 

collapse (sum) ambula hx procedimientos_qx Imagenes_dx Laboratorios Medicamentos Otros_servicios , by( TIPO_DOCUMENTO IDENTIFICACION year)
	
	//verificacion de que la sumatoria de los conteos de las variables es = a lo que había antes del colapse 
	//tabstat ambula hx procedimientos_qx Imagenes_dx Laboratorios Medicamentos Otros_servicios, statistics( sum )
	//di  202537   +  30892  +  189908   +  89485  +  622303  + 2538869 +   204979
	// concuerda
	
	
////Exportando la Tabla final que tiene informacion de 2019 y 2020 sobre lo planteado inicialmente 
save "C:\Users\gbuit\Dropbox\HUN\Estandares clinicos\Priorizacion HUN\Bases de datos\HUN_conteo_servicios_19-20j.dta", replace















