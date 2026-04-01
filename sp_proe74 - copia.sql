-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS

-- Creado:	23/07/2014 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe74;
 
create procedure sp_proe74(a_poliza CHAR(10), a_unidad CHAR(5), a_producto CHAR(5), a_cobertura CHAR(5)) returning DECIMAL(5,2);


DEFINE _no_documento        CHAR(20); 
DEFINE _cod_ramo          	CHAR(3);
DEFINE _descuento_max		DECIMAL(5,2);
DEFINE _tipo_descuento      SMALLINT;
DEFINE _cant_g              SMALLINT;
DEFINE _cant_p              SMALLINT;
DEFINE _cant_s 				SMALLINT;
DEFINE _no_motor	        CHAR(50);
DEFINE _cod_modelo			CHAR(5);
DEFINE _cod_tipo			CHAR(3);
DEFINE _tipo_auto			SMALLINT;
DEFINE _no_poliza			CHAR(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe74.trc"; 
--trace on;

LET _descuento_max = 0;
LET _tipo_descuento = 0;

SELECT no_documento, cod_ramo
  INTO _no_documento, _cod_ramo
  FROM emipomae
 WHERE no_poliza = a_poliza;

IF _cod_ramo not in ("002", "023") THEN
   Return 0.00;
END IF 

-- Buscando informacion del tipo de vehiculo 1 Sedan, 2 Suv, 3 Pick Up
select no_motor
  into _no_motor
  from emiauto
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select cod_modelo
  into _cod_modelo
  from emivehic
 where no_motor = _no_motor;

select cod_tipoauto
  into _cod_tipo
  from emimodel
 where cod_modelo = _cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;

if _tipo_auto = 0 then
   Return 0.00;
end if

-- Conteo de siniestros con evento colision con estatus de audiencia perdido

let _no_poliza = sp_sis21(_no_documento);

SELECT COUNT(*)
  INTO _cant_p
  FROM recrcmae
 WHERE no_poliza = _no_poliza
   AND estatus_audiencia not in (1, 7)
   AND cod_evento  in ('016','002','003','004','006','007','011','050','059','138')	      --> esperar la lista de los eventos que debemos contar
   AND actualizado = 1;
   
   
-- Busqueda de los descuentos 
SELECT descuento_max, 
	   tipo_descuento
  INTO _descuento_max, 
       _tipo_descuento 
  FROM prdcobpd
 WHERE prdcobpd.cod_producto  = a_producto
   AND prdcobpd.cod_cobertura = a_cobertura;

-- Eliminando descuento de buena experiencia
IF _tipo_descuento IN (1,2) THEN
	delete from emiunide
	 where no_poliza = a_poliza
	   and no_unidad = a_unidad
	   and cod_descuen = "001";

	if (_tipo_auto = 1 and _cant_p = 1) or (_tipo_auto in (2,3) and _cant_p = 0) then 
	    update emipouni
	       set cod_tipo_tar	= '002'
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad;
	end if

END IF 

IF  _cant_p = 0 THEN   --Sin siniestro o con siniestro pero sin perdidos
   if _tipo_descuento = 1 then	--> Descuento RC igual para Sedan, Suv, Pick Up
   elif _tipo_descuento = 2 then --> Descuento Combinado Casco
		if _tipo_auto = 1 then
			let	_descuento_max = 50;
		else
        	let _descuento_max = sp_proe72(a_poliza,a_unidad);
		end if
   else
		let _descuento_max = 0;
   end if
ELIF  _cant_p = 1 THEN --Con un reclamo perdido
   if _tipo_descuento = 1 then	--> Descuento RC igual para Sedan, Suv, Pick Up
   elif _tipo_descuento = 2 then --> Descuento Combinado Casco
		if _tipo_auto in (2, 3) then
			let	_descuento_max = 50;
		else
        	let _descuento_max = sp_proe72(a_poliza,a_unidad);
		end if
   else
		let _descuento_max = 0;
   end if
ELIF  _cant_p > 1 THEN --Con mas de un reclamo perdido
	let _descuento_max = 0;
END IF

return _descuento_max;

end procedure
