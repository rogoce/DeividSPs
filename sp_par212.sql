-- Procedure que crea la poliza para la U

drop procedure sp_par212;
create procedure sp_par212(_no_poliza CHAR(10), a_producto CHAR(5))
returning integer,
          char(100);

--define _no_poliza		char(10);
define _no_unidad		char(5);
define _nombre			varchar(100);
define _apellido        varchar(40);
define _cod_cliente		char(10);
define _cod_ruta        char(5);
define _tipo_asegurado  char(2);
define _producto        char(5);
define _producto2       char(5);
define _usuario			char(8);
define _seg_nom         char(40);
define _seg_ape         char(40);

define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_suscripcion date;

define _error			integer;
define _contador		integer;
define _numero			integer;
define _contstring      char(50);

define _cant            integer;
define _suma_asegurada  dec(16,2);

set isolation to dirty read;

--set debug file to "sp_par212.trc";
--trace on;

begin 
on exception set _error
	return _error, trim(_nombre) || " " || trim(_apellido) || " " || "Error al Actualizar el registro";
end exception

let _contador  = 0;

select vigencia_inic,
       vigencia_final,
	   fecha_suscripcion,
	   user_added
  into _vigencia_inic,
       _vigencia_final,
	   _fecha_suscripcion,
	   _usuario
  from emipomae
 where no_poliza = _no_poliza;
 
select suma_asegurada
  into _suma_asegurada
  from clisalma
 where no_lote = _no_poliza;
 
if _suma_asegurada is null then
	let _suma_asegurada = 0.00;
end if
 
foreach
	select cod_ruta 
	  into _cod_ruta
	  from emigloco
	 where no_poliza = _no_poliza
	exit foreach;
end foreach 

select count(*)
  into _cant
  from emipouni
 where no_poliza = _no_poliza;

if _cant > 0 then
	let _contador  = sp_sis189(_no_poliza);
else            							
	delete from emidepen where no_poliza = _no_poliza;
	delete from emibenef where no_poliza = _no_poliza;
	delete from emipocob where no_poliza = _no_poliza;
	delete from emifacon where no_poliza = _no_poliza;
	delete from emipouni where no_poliza = _no_poliza;
end if

foreach
 select nombre,
        apellido,
        cod_cliente,
		tipo_asegurado,
		producto,
        segundo_nombre,
	    segundo_apellido		
   into _nombre,
        _apellido,
        _cod_cliente,
		_tipo_asegurado,
		_producto,
		_seg_nom,
		_seg_ape
   from clisalde
  where no_lote = _no_poliza
  
    if _nombre is null then
		let _nombre = "";
	end if
    if _apellido is null then
		let _apellido = "";
	end if
    if _seg_nom is null then
		let _seg_nom = "";
	end if
    if _seg_ape is null then
		let _seg_ape = "";
	end if

    If _producto <> "" or _producto is not null Then
		let _producto2 = _producto;
	Else 	
		let _producto2 = a_producto;
	End If

	-- Determinar el Numero de la Unidad
	If trim(_tipo_asegurado) = 'A' Then
		let _contador = _contador + 1;
		let _contstring	= _contador;
	End If

	LET _no_unidad  = '00000';

	IF _contador > 9999 THEN
		LET _no_unidad      = _contador;
	ELIF _contador > 999 THEN
		LET _no_unidad[2,5] = _contador;
	ELIF _contador > 99  THEN
		LET _no_unidad[3,5] = _contador;
	ELIF _contador > 9  THEN
		LET _no_unidad[4,5] = _contador;
	ELSE
		LET _no_unidad[5,5] = _contador;
	END IF

	-- Actualizar el codigo del cliente
	If trim(_tipo_asegurado) = 'A' Then
	    let _contstring = _contstring || ", emipouni";
	    insert into emipouni(
		no_poliza,
		no_unidad,
		cod_ruta,
		cod_producto,
		cod_asegurado,
		descuento,
		vigencia_inic,
		vigencia_final,
		desc_unidad,
		activo,
		facturado,
		fecha_emision,
		prima_suscrita,
		prima_retenida,
		suma_asegurada
		)
		values(
		_no_poliza,
		_no_unidad,
		_cod_ruta,
		_producto2,
		_cod_cliente,
		0,
		_vigencia_inic,
		_vigencia_final,
		trim(_nombre) || " " || trim(_seg_nom) || " " || trim(_apellido) || " " || trim(_seg_ape),
		1,
		1,
		_fecha_suscripcion,
		0,
		0,
		_suma_asegurada
		);
	Elif trim(_tipo_asegurado) = 'DC' Then
	    let _contstring = _contstring || ", emidepenDC";
	    insert into emidepen(
		no_poliza,
		no_unidad,
		cod_cliente,
		cod_parentesco,
		activo,
		prima,
		user_added,
		date_added
		)
		values(
		_no_poliza,
		_no_unidad,
		_cod_cliente,
		'001',
		1,
		0,
		_usuario,
		current
		);
	Elif trim(_tipo_asegurado) = 'DH' Then
	    let _contstring = _contstring || ", emidepenDH";
	    insert into emidepen(
		no_poliza,
		no_unidad,
		cod_cliente,
		cod_parentesco,
		activo,
		prima,
		user_added,
		date_added
		)
		values(
		_no_poliza,
		_no_unidad,
		_cod_cliente,
		'002',
		1,
		0,
		_usuario,
		current
		);
	Else
	    let _contstring = _contstring || ", emibenef";
	    insert into emibenef(
		no_poliza,
        no_unidad,
        cod_cliente,
 		cod_parentesco,
		benef_desde,
		nombre
		)
		values(
		_no_poliza,
		_no_unidad,
		_cod_cliente,
		'009',
		_vigencia_inic,
		_nombre
		);
	End If
end foreach
end
return 0, "Actualizacion Exitosa";
end procedure
