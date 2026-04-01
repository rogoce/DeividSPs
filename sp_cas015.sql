-- Retorna las Unidades de una Poliza
-- 
-- Creado    : 10/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 10/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas015;

create procedure sp_cas015(a_no_documento char(20))
returning char(5),
		  dec(16,2),
		  char(30),
		  char(30),
		  char(10),
		  char(100),
		  char(50),
		  char(50),
		  smallint,
		  varchar(50),
		  smallint,
		  char(10);


define _no_poliza		char(10);
define _no_unidad		char(5);
define _suma			dec(16,2);
define _no_motor		char(30);
define _cod_tipoveh		char(3);
define _cod_marca		char(5);
define _cod_modelo		char(5);
define _cod_tipoauto	char(3);
define _nombre_marca	char(50);
define _nombre_modelo	char(50);
define _nombre_tipoveh	char(50);
define _nombre_tipoauto	char(50);
define _no_chasis		char(30);
define _placa			char(10);
define _descripcion		char(100);
define _cod_ramo		char(3);
define _cod_acreedor	char(5);
define _nombre_acre		char(50);
define _ano_auto		smallint;
define _cod_color       char(3);
define _color           varchar(50);
define _ano_tarifa      smallint;

set isolation to dirty read;

let _no_poliza = sp_sis21(a_no_documento);
let _color ="";
let _ano_tarifa= 0;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;


foreach
 select no_unidad,
        suma_asegurada
   into _no_unidad,
		_suma
   from emipouni
  where no_poliza = _no_poliza

	let _no_motor	 	= "";
	let _no_chasis	 	= "";
	let _placa		 	= "";
	let _descripcion 	= "";
	let _nombre_tipoveh	= "";
	let _ano_auto       = null;

	if _cod_ramo = "002" or _cod_ramo = "020" or _cod_ramo = "023" then

		select cod_tipoveh,
		  	   no_motor,
			   ano_tarifa
		  into _cod_tipoveh,
		  	   _no_motor,
			   _ano_tarifa
		  from emiauto
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;

 		let _ano_tarifa = _ano_tarifa + 1;
 
		if _ano_tarifa = 0 then
			let _ano_tarifa = 1;
		end if
			 
		select nombre
		  into _nombre_tipoveh
		  from emitiveh
		 where cod_tipoveh = _cod_tipoveh;

		select cod_marca,
		       cod_modelo,
			   no_chasis,
			   placa,
			   ano_auto,
			   cod_color
		  into _cod_marca,
		       _cod_modelo,
			   _no_chasis,
			   _placa,
			   _ano_auto,
			   _cod_color
		  from emivehic
		 where no_motor = _no_motor;
		 
--		let _ano_tarifa =  year(today) - _ano_auto + 1;

--		let _ano_tarifa =  2021 - _ano_auto + 1;

		select nombre
		  into _color
		  from emicolor
		 where cod_color=_cod_color;


		select nombre
		  into _nombre_marca
		  from emimarca
		 where cod_marca = _cod_marca;

		select nombre,
		       cod_tipoauto
		  into _nombre_modelo,
		       _cod_tipoauto
		  from emimodel
		 where cod_modelo = _cod_modelo;

		select nombre
		  into _nombre_tipoauto
		  from emitiaut
		 where cod_tipoauto = _cod_tipoauto;

		let _descripcion = trim(_nombre_marca) || " " || trim(_nombre_modelo) || " - " || _nombre_tipoauto;
	
	end if

	let _cod_acreedor = null;

	foreach
	 select cod_acreedor
	   into _cod_acreedor
	   from emipoacr
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad
	    	exit foreach;
	end foreach
	
	if _ano_auto is null then
		let _ano_auto = null;
	end if

	if _cod_acreedor is null then
		let _nombre_acre = "";
	else
		select nombre
		  into _nombre_acre
		  from emiacre
		 where cod_acreedor = _cod_acreedor;
	end if

	return _no_unidad,
	       _suma,
		   _no_motor,
		   _no_chasis,
		   _placa,
		   _descripcion,
		   _nombre_tipoveh,
		   _nombre_acre,
		   _ano_auto,
		   _color,
		   _ano_tarifa,
		   _no_poliza
		   with resume;
		   	
end foreach

end procedure