-- Procedimiento que Realiza la Carga a las tablas de Emision desde Cotizacion

-- Creado    : 14/03/2003 - Autor: Amado Perez  
-- Modificado: 02/10/2012 - Autor: Amado Perez, se puedan crear registros cono sin informacion del auto 

drop procedure ap_desc_cob;

create procedure "informix".ap_desc_cob()
RETURNING INTEGER;

--}

--- Actualizacion de Polizas

DEFINE r_anos          smallint;
DEFINE _porc_depre     DEC(5,2);
DEFINE _porc_depre_uni DEC(5,2);
DEFINE _porc_depre_pol DEC(5,2);
DEFINE _no_unidad      CHAR(5); 
DEFINE _cod_cobertura  CHAR(5); 
DEFINE _cod_producto   CHAR(5); 
DEFINE _valor_asignar  CHAR(1); 
DEFINE _periodo		   CHAR(7);
DEFINE _cant_unidades  INTEGER; 
DEFINE _suma_asegurada INTEGER;
DEFINE _no_motor       CHAR(30);
DEFINE _suma_decimal   DEC(16,2);
DEFINE _suma_difer	   DEC(16,2);

DEFINE li_dia		   SMALLINT;
DEFINE li_mes		   SMALLINT;
DEFINE li_ano		   SMALLINT;
DEFINE ld_fecha_1_pago DATE;
DEFINE li_no_pagos	   SMALLINT;
DEFINE ls_cod_perpago  CHAR(3);
DEFINE li_meses		   SMALLINT;
DEFINE _cotizacion     CHAR(10);
DEFINE _cod_impuesto   CHAR(3);
DEFINE _factor_impuesto DEC(5,2);
DEFINE _serie          SMALLINT;

DEFINE _unidad	       CHAR(5);
DEFINE _unidadcadena   CHAR(5);
DEFINE _unidad_key     CHAR(5);
DEFINE _decnuevo       SMALLINT; 
DEFINE _anoauto       INTEGER; 
DEFINE _codmarca, _cod_ruta, _codproducto CHAR(5);
DEFINE _codmodelo      CHAR(5);
DEFINE _codtipo        CHAR(3);
DEFINE _capacidad      SMALLINT;
DEFINE _peso           CHAR(20);
DEFINE _nromotor       CHAR(50);
DEFINE _anosauto  	   SMALLINT;
DEFINE _valororiginal  DEC(16,2);
DEFINE _valoractual    DEC(16,2);
DEFINE _nrochasis, _observacion  CHAR(50);
DEFINE _placa          CHAR(30); 
DEFINE _usandocar      CHAR(1);
DEFINE _vin            CHAR(30);
DEFINE _codacreedor    CHAR(5);
DEFINE _porcdescbe	   DEC(5,2);
DEFINE _porcdescflota  DEC(5,2);
DEFINE _porcdescesp    DEC(5,2);
DEFINE _porcrecargou   DEC(5,2);
DEFINE _totprimaanual  DEC(16,2);
DEFINE _totprimabruta  DEC(16,2);
DEFINE _totprimaneta   DEC(16,2);
DEFINE _descuentobe	   DEC(16,2);
DEFINE _descuentoflota DEC(16,2);
DEFINE _descuentoesp   DEC(16,2);
DEFINE _impuestos	   DEC(16,2);
DEFINE _desctotal	   DEC(16,2);
DEFINE _recargototal   DEC(16,2);

DEFINE _codcobertura    CHAR(5); 
DEFINE _orden, _aceptadesc  SMALLINT;
DEFINE _tarifa          DEC(9,2);
DEFINE _deducible       VARCHAR(50);
DEFINE _limite1         DEC(16,2);
DEFINE _limite2		   DEC(16,2);
DEFINE _primaanual, _prima_anual DEC(16,2);
DEFINE _primabruta	   DEC(16,2);
DEFINE _descuento	   DEC(16,2);
DEFINE _recargo		   DEC(16,2);
DEFINE _primaneta, _prima_neta  DEC(16,2);
DEFINE _factorvigencia  DEC(9,2);
DEFINE _desclimite1     VARCHAR(50);
DEFINE _desclimite2	    VARCHAR(50);
DEFINE v_cotizacion_r, _cadena  int;
DEFINE v_fecha_r 	    DATE;
DEFINE v_usuario_r      CHAR(8);
define _error           smallint; 
DEFINE _fechainicio		datetime year to minute;
DEFINE _fecha_emision	datetime year to minute;
define _porc_comision	dec(5,2);
define _v               smallint;
define _valor_parametro VARCHAR(50);
define _sum_descuento   dec(16,2);

DEFINE _codcolor        char(3);
DEFINE _transmision     integer;
DEFINE _tipo_motor      varchar(50);
define _tamano          varchar(50);
DEFINE _num_pasajeros   integer;
DEFINE _tipo_auto       integer;
define _frenos          char(3);
define _air_bag         char(3);
define _tam_rines       integer;
define _kilome          integer;
define _nombre_marca    varchar(30);
define _nombre_modelo   varchar(30);
define _cant            smallint;
define _desc_comb       dec(16,2);
define _desc_modelo     dec(16,2);

define v_cotizacion   int;
define v_poliza_nuevo char(10);
define v_documento    char(20);

define _cont1, _cont2, _cont3, _cont4 smallint;

--SET DEBUG FILE TO "ap_desc_cob.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION


	foreach with hold
		select nrocotizacion,
		       nrounidad,
		       codcobertura,
			   desc_comb,
			   desc_modelo
		  into v_cotizacion,
		       _unidad,
		       _codcobertura,  
               _desc_comb,
               _desc_modelo			   
		  from wf_coberturas
		 where (desc_comb > 0 
		    or desc_modelo > 0)
		  
		 Let _cotizacion = v_cotizacion; 

		 let _cadena = _unidad;
		 let _unidadcadena = "00000";

		 if _cadena > 9999  then
			let _unidadcadena[1,5] = _cadena;
		 elif _cadena > 999 then
			let _unidadcadena[2,5] = _cadena;
		 elif _cadena > 99  then
			let _unidadcadena[3,5] = _cadena;
		 elif _cadena > 9   then
			let _unidadcadena[4,5] = _cadena;
		 else
			let _unidadcadena[5,5] = _cadena;
		 end if

		 let _unidad_key = TRIM(_unidadcadena);
		  		 
		 if _desc_comb is null then
		 	let _desc_comb = 0;
		 end if
		 
		 if _desc_modelo is null then
		 	let _desc_modelo = 0;
		 end if
	
    foreach	
		select no_poliza, no_documento
          into v_poliza_nuevo, v_documento 	
          from emipomae
         where cotizacion = _cotizacion	
		   and nueva_renov = 'N'
           and actualizado = 1		 		   
		
		
		if _desc_comb is not null and _desc_comb <> 0 THEN
			   
			begin

				ON EXCEPTION IN(-239,-268, -691)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'004',			 -- cod_descuen
				_desc_comb);	 -- porc_descuen 0
			end
		end if
		
		if _desc_modelo is not null and _desc_modelo <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268, -691)                     
														  
				END EXCEPTION                             
				insert into emicobde(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				_codcobertura,
				'005',			 -- cod_descuen
				_desc_modelo);	 -- porc_descuen 0
			end
		end if

		if _desc_comb is not null and _desc_comb <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268, -691)                     
														  
				END EXCEPTION                             
				insert into endcobde(
				no_poliza,
				no_unidad,
				no_endoso,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				'00000',
				_codcobertura,
				'004',			 -- cod_descuen
				_desc_comb);	 -- porc_descuen 0
			end
		end if
		
		if _desc_modelo is not null and _desc_modelo <> 0 THEN
			begin

				ON EXCEPTION IN(-239,-268, -691)                     
														  
				END EXCEPTION                             
				insert into endcobde(
				no_poliza,
				no_unidad,
				no_endoso,
				cod_cobertura,
				cod_descuen,
				porc_descuento
				)
				values (
				v_poliza_nuevo,	 -- no_poliza
				_unidad_key,	 -- no_unidad
				'00000',
				_codcobertura,
				'005',			 -- cod_descuen
				_desc_modelo);	 -- porc_descuen 0
			end
		end if
	 end foreach
	end foreach

end

RETURN 0;
end procedure;
