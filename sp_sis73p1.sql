-- Creaci¢n de tablas : Paso 1 - Proyecto: Actualizaci¢n de los codigos con la tabla de Leasing  
-- Creado             : 1/10/2007 - Autor: Rub‚n Dar¡o Arn ez S nchez 
 --drop procedure       sp_sis73p1;

create procedure "informix".sp_sis73p1()
returning integer,
        char(100);

define _cod_errado   char(10);
define _cod_correcto char(10);
define _ind_leasing  char(1);
define _tiempo	     datetime year to fraction(5);
define _error	     integer;
define _nom_tabla    char(30);
define _cnt			 integer;
define _no_doc		 char(20);

define _nombre       varchar(100);
define _p_nom   	 char(100);
define _s_nom     	 char(40);
define _p_ape      	 char(40);
define _s_ape     	 char(40);
define _c_ape      	 char(40);
define _nom_raz      varchar(100);
define _no_poliza    char(10);
define _no_documento char(20);
define _no_unidad	 char(5);
define _no_endoso    char(5);


CREATE TEMP TABLE temp_clidepur(
cod_errado           char(10),
cod_correcto         char(10),
user_changed         char(8),
date_changed         datetime year to fraction(5),
nom_tabla            varchar(30,0),
no_poliza			 char(10),  
no_endoso			 char(5),  
no_unidad			 char(5),  
no_documento         char(20)  
) WITH NO LOG;

let _tiempo      = current;
let _no_poliza   = "";
let _p_nom       = ""; 
let _s_nom       = "";
let	_p_ape       = "";
let	_s_ape       = "";
let	_c_ape       = "";
let _cod_errado  = ""; 
let _cod_correcto= "";
let _nombre      = "";
let _nom_raz     = "";
let _no_poliza   = "";
let _no_documento= "";
let _no_unidad	 = "";
let _no_endoso   = "";


foreach 
     select cod_errado,
			cod_leasin,
			p_nombre, 
			s_nombre, 
			a_pater, 
			a_matern,
			a_casada  
	   into _cod_errado,
			_cod_correcto,
			_p_nom,
			_s_nom,
			_p_ape,
			_s_ape,
			_c_ape
	   from leasing

	   
	 --**ENDEDUNI**--
	
		select count(*)
		  into _cnt
		  from tendeduni
		 where cod_cliente = _cod_errado;
   		   
	 if _cnt > 0 then
        let _nom_tabla ="ENDEDUNI" ;

		foreach
		 select no_poliza,
				no_unidad,
				no_endoso
	   	  into _no_poliza,
		  	   _no_unidad,
			   _no_endoso
	   	  from tendeduni
	  	 where cod_cliente = _cod_errado

	  
     	insert into temp_clidepur(
		cod_errado,
		cod_correcto,
		user_changed,
		date_changed,
		nom_tabla,
		no_poliza,
		no_endoso,
		no_unidad,
		no_documento
		)
		values(
		_cod_errado,
		_cod_correcto,
		"RARNAEZ",
		_tiempo,
		_nom_tabla,
		_no_poliza,												   
		_no_endoso,
		_no_unidad,
		""
		);

		
		update tendeduni
		   set cod_cliente = _cod_correcto
		 where no_poliza   = _no_poliza and
			   no_endoso   = _no_endoso and
		       no_unidad   = _no_unidad;

		end foreach

		end if

   	 --**EMIPOUNI**--

	 select count(*)
	   into _cnt
	   from temipouni
	  where cod_asegurado = _cod_errado;

	 if _cnt > 0 then

		foreach
			 select no_poliza,
					no_unidad
			   into _no_poliza,
					_no_unidad
			   from temipouni
			  where cod_asegurado = _cod_errado
		
        let _nom_tabla = "EMIPOUNI";
				  
	 	insert into temp_clidepur(
		cod_errado,
		cod_correcto,
		user_changed,
		date_changed,
		nom_tabla,
		no_poliza,
		no_endoso,
		no_unidad,
		no_documento
		)
		values(
		_cod_errado,
		_cod_correcto,
		"RARNAEZ",
		_tiempo,
		_nom_tabla,
		_no_poliza,
		"",
		_no_unidad,
		""
	    );
		update temipouni
		   set cod_asegurado = _cod_correcto
		 where no_poliza   = _no_poliza and
		       no_unidad   = _no_unidad;
	   

		--**EMIPOMAE**--

        let _nom_tabla = "EMIPOMAE";

	   	select no_documento
		  into _no_documento
		  from temipomae
		 where no_poliza = _no_poliza;

	--	insert into clidepur(
		insert into temp_clidepur(
		cod_errado,
		cod_correcto,
		user_changed,
		date_changed,
		nom_tabla,
		no_poliza,
		no_endoso,
		no_unidad,
		no_documento
		)
		values(						   
		_cod_errado,
		_cod_correcto,
		"RARNAEZ",
		_tiempo,
		_nom_tabla,
		_no_poliza,
		"",
		"",
		_no_documento
		);

	   	update temipomae
		   set cod_contratante  = _cod_errado,
		       cod_pagador      = _cod_errado,
		       leasing          = 1 
		 where no_poliza 	    = _no_poliza; 
	   --	 and   no_documento = _no_documento;

		end foreach
		-- se adiciono el end if
		end if
		
		if _nom_raz is null then
		   let _nom_raz = "";
		end if
		if _nombre  is null then
		   let _nombre = "";
		end if
		if _p_nom is null then
		   let _p_nom = "";
		end if
		if _s_nom is null then
		   let _s_nom = "";
		end if
		if _p_ape is null then
		   let _p_ape = "";
		end if
		if _s_ape is null then
		   let _s_ape  = "";
		end if
		if _c_ape is null then
		   let _c_ape  = "";
		end if


		 let _nombre = trim(_p_nom) || " " || trim(_s_nom) || " " || trim(_p_ape) || " " || trim(_s_ape) || " " || trim(_c_ape);
	   	 
		 update tcliclien
		   set nombre           = _nombre,
		       nombre_razon     = _nombre,
			   aseg_primer_nom  = trim(_p_nom),
		   	   aseg_segundo_nom = trim(_s_nom),
		   	   aseg_primer_ape  = trim(_p_ape),
		   	   aseg_segundo_ape = trim(_s_ape),
		   	   aseg_casada_ape  = trim(_c_ape)
		 where cod_cliente      = _cod_errado;
     
end foreach

return 0, "Actualizacion Exitosa";

end procedure;



