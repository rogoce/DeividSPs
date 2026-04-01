-- Crea una poliza de incendio partir de una multiriesgo 
-- Creado: 19/05/2013 - Autor: Enocjahaziel Carrasco
-- se inserta un tipo blob
drop procedure sp_web26;
create procedure "informix".sp_web26(var_no_poliza char(10))
returning smallint, char(20);

define  _prima decimal(10,2);
define contador_valor decimal(10,2);
define  _cod_producto varchar(5);
define  _descuento_b decimal(10,2);
define  _recargo_b decimal(10,2);
define  _descuento_c decimal(10,2);
define  _recargo_c decimal(10,2);
define  _cod_compania char(3);
define  _cod_sucursal char(3);
define  _sucursal_origen char(3);
define  _cod_grupo char(5);
define  _cod_perpago char(3);
define  _cod_tipocalc char(3);
define  _cod_subramo char(3);
define  _cod_formapag char(3);
define  _cod_tipoprod char(3);
define  _cod_contratante char(10);
define  _cod_pagador char(10);
define  _serie integer;
define  _descuento dec(16,2);
define  _recargo dec(16,2);
define  _prima_neta dec(16,2);
define  _impuesto dec(16,2);
define  _prima_bruta dec(16,2);
define  _prima_suscrita dec(16,2);
define  _prima_retenida dec(16,2);
define  _tiene_impuesto INTEGER;
define  _vigencia_inic DATE;
define  _vigencia_final DATE;
define  _fecha_suscripcion DATE;
define  _fecha_impresion DATE;
define  _no_pagos INTEGER;
define  _impreso INTEGER;
define  _nueva_renov  CHAR(1);
define  _estatus_poliza INTEGER;
define  _direc_cobros char(50);
define  _por_certificado CHAR(1);
define  _actualizado INTEGER;
define  _dia_cobros1  SMALLINT;
define  _dia_cobros2 SMALLINT;
define  _fecha_primer_pago DATE;
define  _date_changed DATE;
define  _renovada INTEGER;
define  _date_added  DATE;
define  _periodo char(7);
define  _carta_aviso_canc CHAR(1);
define  _carta_prima_gan CHAR(1);
define  _carta_vencida_sal CHAR(1);
define  _carta_recorderis CHAR(1);
define  _cobra_poliza CHAR(1);
define  _user_added CHAR(8);
define  _ult_no_endoso INTEGER;
define  _declarativa INTEGER;
define  _abierta INTEGER;
define  _no_renovar INTEGER;
define  _perd_total INTEGER;
define  _anos_pagador INTEGER;
define  _saldo_por_unidad dec(16,2);
define  _factor_vigencia INTEGER;
define  _suma_asegurada dec(16,2);
define  _incobrable CHAR(1);
define  _saldo dec(16,2);
define  _posteado CHAR(1);
define  _cod_origen CHAR(3);
define  _cotizacion CHAR(20);
define  _de_cotizacion INTEGER;
define  _gastos INTEGER;
define  _subir_bo INTEGER;
define  _leasing INTEGER;
define  _linea_rapida INTEGER;
define  _no_recibo varchar(20);
define _no_poliza varchar(20);
DEFINE _error        	integer;
DEFINE _error_isam   	integer;
DEFINE _error_desc  	CHAR(30);
define _cod_ramo           char(3);
define v_cod_subramo           char(3);
define v_cod_producto       char(10);
define _cod_ruta            char(5);	
define _fecha_actual        date;
define _cod_impuesto    char(3);
define _factor_impuesto dec(16,2);
define _cod_cobertura   char(10);
define _li_orden           smallint;
define _valor_tar_unica smallint;
define _deducible       dec(16,2);
define _nombre          varchar(50);
define _limite_1   dec(16,2);
define _limite_2   dec(16,2);
define _rango_monto1   dec(16,2);
define _rango_monto2   dec(16,2);
define _valor   dec(16,2);
define _cod_agente varchar(10);
define _porcentaje_comision integer;
define _li_reg integer;
define _cantidad integer;
define _li_cod_contrato varchar(10);
define _li_porc_partic_suma  dec(16,2);
define _li_porc_partic_prima dec(16,2);
define porcentaje_div dec(16,2);
define _cien dec(16,2);

define v_descripcion REFERENCES BYTE;

let _cien = 100;
let contador_valor=0;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_web26.trc";
--trace on;

    let _cod_ramo = '003';
let v_cod_subramo = '001';
let v_cod_producto = '01978';
let _no_pagos = 1;
let _fecha_actual = sp_sis26();
foreach
      select
           cod_compania, --2
           cod_sucursal, --3
           sucursal_origen, --4
	       cod_grupo,       --5
           cod_perpago,     --6
           cod_tipocalc,    --7
        --   cod_ramo,        --8
        --   cod_subramo,     --9
           cod_formapag ,   --10
           cod_tipoprod ,   --11
	       cod_contratante, --12
           cod_pagador,     --13
        --   serie,           --14
           --prima,           --15
           descuento,       --16
           recargo ,        --17
 --          prima_neta,      --18
           impuesto,        --19
 -- 	     prima_bruta,     --20
 --          prima_suscrita,  --21
 --          prima_retenida,  --22
           tiene_impuesto,  --23
           vigencia_inic,   --24
           vigencia_final,  --25
	       fecha_suscripcion,--26
           fecha_impresion,  --27
           no_pagos,       --28
           impreso,        --29
           nueva_renov,    --30
           estatus_poliza, --31
           direc_cobros,    --32
           por_certificado,  --33
           actualizado ,     --34
	       dia_cobros1,      --35
	       dia_cobros2,       --36
           fecha_primer_pago,     --37
      	   date_changed,   --38
           renovada,         --39
           date_added,       --40
           periodo,    --41
           carta_aviso_canc, --42
           carta_prima_gan,  --43
           carta_vencida_sal,--44
           carta_recorderis, --45
           cobra_poliza,     --46
           user_added,       --47
           ult_no_endoso,    --48
           declarativa,       --49
           abierta, --50
           no_renovar,--51
           perd_total, --52
           anos_pagador, --53
           saldo_por_unidad, --54
           factor_vigencia,   --55
	       suma_asegurada,   --56
           incobrable,   --57
           saldo,       --58
           posteado,     --59
           cod_origen,    --60
           cotizacion,    --61
           de_cotizacion,  --62
           gastos,         --63
           subir_bo,        --64
           leasing,         --65
           linea_rapida,     --66    
           no_recibo             --67
      into
	  _cod_compania  ,--2
	  _cod_sucursal , --3
	  _sucursal_origen,--4
	  _cod_grupo,      --5
	  _cod_perpago,    --6
	  _cod_tipocalc,   --7
--	  _cod_ramo,       --8
--	  _cod_subramo,    --9
	  _cod_formapag,   --10
	  _cod_tipoprod,   --11
	  _cod_contratante,--12
	  _cod_pagador,    --13
	--  _serie,          --14
---	  _prima,          --15
	  _descuento,      --16
	  _recargo,        --17
--	  _prima_neta,     --18
	  _impuesto,       --19
--	  _prima_bruta,    --20
--	  _prima_suscrita, --21
--	  _prima_retenida, --22
	  _tiene_impuesto, --23
	  _vigencia_inic,  --24
	  _vigencia_final, --25
	  _fecha_suscripcion,--26
	  _fecha_impresion, --27
	  _no_pagos,        --28
      _impreso,        --29
	  _nueva_renov,     --30
	  _estatus_poliza,  --31
	  _direc_cobros,    --32
	  _por_certificado, --33
	  _actualizado,     --34
	  _dia_cobros1,     --35
	  _dia_cobros2,     --36
	  _fecha_primer_pago,--37
	  _date_changed,     --38
	  _renovada,         --39
	  _date_added,       --40
	  _periodo,          --41
	  _carta_aviso_canc, --42
	  _carta_prima_gan,  --43
	  _carta_vencida_sal,--44
	  _carta_recorderis, --45
	  _cobra_poliza,     --46
	  _user_added,       --47
	  _ult_no_endoso,    --48
	  _declarativa,      --49
	  _abierta,          --50
	  _no_renovar,  --51
	  _perd_total,   --52
	  _anos_pagador,   --53
	  _saldo_por_unidad,  --54
	  _factor_vigencia,  --55
	  _suma_asegurada,   --56
	  _incobrable,       --57
	  _saldo,          --58
	  _posteado,       --59
	  _cod_origen,    --60
	  _cotizacion,  --61
	  _de_cotizacion, --62
	  _gastos,   --63
	  _subir_bo, --64
	  _leasing,  --65
	  _linea_rapida,--66        
          _no_recibo      --67
      from emipomae where no_poliza = var_no_poliza

end foreach
                foreach
                select cod_ruta, serie
                into
                _cod_ruta,
                _serie
                 from rearumae WHERE cod_ramo =  _cod_ramo and activo = 1 and _vigencia_inic between vig_inic and vig_final and ruta_web = 1 ORDER BY cod_ruta DESC
                 end foreach

  CALL sp_sis13('001', 'PRO', '02', 'par_no_poliza') returning _no_poliza;
  INSERT INTO emipomae(no_poliza,
                     cod_compania,
                     cod_sucursal,
                     sucursal_origen,
                     cod_grupo,
					 cod_perpago,
					 cod_tipocalc,
					 cod_ramo,
					 cod_subramo,
		             cod_formapag,
					 cod_tipoprod,
					 cod_contratante,
					 cod_pagador,
					 serie,
					 prima,descuento,
					 recargo,
					 prima_neta,
					 impuesto,
					 prima_bruta,
	     	         prima_suscrita,
					 prima_retenida, 
					 tiene_impuesto, 
					 vigencia_inic, 
					 vigencia_final, 
					 fecha_suscripcion, 
					 fecha_impresion,
					 no_pagos,
					 impreso,
					 nueva_renov,
					 estatus_poliza,
					 direc_cobros,
					 por_certificado,
					 actualizado,
					 dia_cobros1,
					 dia_cobros2,
					 fecha_primer_pago,
					 date_changed, renovada, date_added,
					 periodo, carta_aviso_canc, carta_prima_gan, carta_vencida_sal, carta_recorderis, cobra_poliza, user_added,
					 ult_no_endoso, declarativa, abierta, no_renovar, perd_total, anos_pagador, saldo_por_unidad, factor_vigencia,
					 suma_asegurada, incobrable,
					 saldo, posteado, cod_origen,
					 cotizacion, de_cotizacion, gastos,subir_bo, leasing, linea_rapida,
					 no_recibo)
                Values(_no_poliza,
               _cod_compania ,
               _cod_sucursal,
               _sucursal_origen,
               _cod_grupo,
               _cod_perpago,
               _cod_tipocalc,
               _cod_ramo,
              v_cod_subramo,
               _cod_formapag,
               _cod_tipoprod,
               _cod_contratante,
               _cod_pagador,
               _serie,
               0,
               _descuento,
               _recargo,
               0,
               _impuesto,
               0,
     	       0,
               0,
               _tiene_impuesto,
               _vigencia_inic,
               _vigencia_final,
               _fecha_suscripcion,
               _fecha_impresion,
			   _no_pagos,
				 _impreso,
				_nueva_renov,
				1,
				_direc_cobros,
				_por_certificado,
				_actualizado,
				_dia_cobros1,
				_dia_cobros2,
				_fecha_primer_pago,
				_date_changed,
                _renovada,
                _date_added,
		        _periodo,
                _carta_aviso_canc,
                _carta_prima_gan,
                _carta_vencida_sal,
                _carta_recorderis,
                _cobra_poliza,
                _user_added,
		        _ult_no_endoso,
                _declarativa,
                _abierta,
                _no_renovar,
                _perd_total,
                _anos_pagador,
                _saldo_por_unidad,
                1,
		        _suma_asegurada,
                _incobrable,
		        _saldo,
                _posteado,
                _cod_origen,
		        _cotizacion,
                _de_cotizacion,
                _gastos,
                _subir_bo,
                _leasing,
                _linea_rapida,
		        _no_recibo);

Insert Into emipouni(no_poliza, --1
					 no_unidad, --2
					 cod_ruta,--3
					 cod_producto,--4
					 cod_asegurado,--5
					 suma_asegurada,--6
					 prima,--7
					 descuento,--8
					 recargo, --9
					 prima_neta,--10
					 impuesto,--11
					 prima_bruta,--12
					 reasegurada,--13
					 vigencia_inic,--14
					 vigencia_final,--15
					 beneficio_max,--16
					 activo,--17
					 prima_asegurado,--18
					 prima_total,--19
					 facturado,
					 perd_total,
					 impreso,
					 fecha_emision,
					 prima_suscrita,
					 prima_retenida,
					 gastos,
					 subir_bo)
					Values(_no_poliza,
			        '00001',
					_cod_ruta,
					v_cod_producto,
					_cod_contratante,
					_suma_asegurada,
					0,
					0,
					0,
					0,
                    0,
					0,
					0,
					_vigencia_inic,
					_vigencia_final,
					0.00,
					1,
					0.00,
					0.00,
					0,
					0,
					1,
					_fecha_actual,
					0,
					0,
					0,
					1);
					
			foreach 			
			Select cod_impuesto
			 into _cod_impuesto
			 From prdimsub
			 Where cod_subramo = v_cod_subramo
			 And cod_ramo = _cod_ramo
			 
			   Select factor_impuesto
			   into _factor_impuesto
			   From prdimpue
               where cod_impuesto = _cod_impuesto;
			   insert into emipolim(no_poliza, cod_impuesto, monto)values(_no_poliza,_cod_impuesto,0);  
			   
		    end foreach
					
foreach				
SELECT   prdcobpd.cod_cobertura , prdcobpd.orden , valor_tar_unica,deducible, prdcober.nombre,
         prdcobpd.desc_limite1,
		 prdcobpd.desc_limite2
         into _cod_cobertura,_li_orden ,_valor_tar_unica,_deducible, _nombre, _limite_1,_limite_2
         FROM prdprod,
         prdcobpd,
         prdcober
         WHERE ( prdcobpd.cod_producto = prdprod.cod_producto ) and
         ( prdcober.cod_cobertura = prdcobpd.cod_cobertura ) and
         ( ( prdprod.cod_producto = '01978' ) AND
         ( prdprod.activo = 1 ) AND
         ( prdcobpd.cob_default = 1 ) )
         ORDER BY prdcobpd.orden ASC
					
		select rango_monto1,rango_monto2,valor 
		  into _rango_monto1,
		       _rango_monto2,
		       _valor 
		 from prdtasec 
		where cod_cobertura = _cod_cobertura 
		  and cod_producto = '01978'; 
			
			IF _rango_monto1 IS NOT NULL THEN	
		 let contador_valor = 	_valor + contador_valor;
  Insert Into emipocob (no_poliza,
                    no_unidad,
					cod_cobertura,
					orden,
					tarifa, 
					deducible,
					limite_1, 
					limite_2,
					prima_anual,
					prima, 
					descuento,
					recargo,
					prima_neta, 
					date_added,
					date_changed,
					factor_vigencia,
					desc_limite1,
		  		    desc_limite2)
				    Values (_no_poliza,
					'00001',
					_cod_cobertura,
					_li_orden,
					_valor_tar_unica, 
					 _deducible,
					 _rango_monto1,
					 _rango_monto2,
					 _valor,
					 _valor, 
					  0, 0,
					  _valor,
					  _fecha_suscripcion, 
					_fecha_suscripcion, 1, 
					_limite_1, _limite_2); 
			else	   
			Insert Into emipocob (no_poliza,
                    no_unidad,
					cod_cobertura,
					orden,
					tarifa, 
					deducible,
					limite_1, 
					limite_2,
					prima_anual,
					prima, 
					descuento,
					recargo,
					prima_neta, 
					date_added,
					date_changed,
					factor_vigencia,
					desc_limite1,
		  		    desc_limite2)
				    Values (_no_poliza,
					'00001',
					_cod_cobertura,
					_li_orden,
					_valor_tar_unica, 
					 _deducible,
					 0,
					 0,
					 0,
					 0, 
					 0, 0,
					 0,
					  _fecha_suscripcion, 
					_fecha_suscripcion, 1, 
					_limite_1, _limite_2); 
				end if 	 
end foreach

update emipouni 
set prima_neta = contador_valor , prima = contador_valor where no_poliza = _no_poliza;

select cod_agente into _cod_agente  from emipoagt where no_poliza = var_no_poliza;

CALL sp_pro305(_cod_agente, _cod_ramo, v_cod_subramo) returning _porcentaje_comision;

Insert Into emipoagt(cod_agente, no_poliza, porc_partic_agt, porc_comis_agt, porc_produc, subir_bo )
	Values(_cod_agente, _no_poliza, 100, _porcentaje_comision, 100, 1 );

	

/*
--Select count(*) into _cantidad  From rearucon Where cod_ruta = _cod_ruta;
--if _cantidad > 0 then 
--Let porcentaje_div =  (_cien /_cantidad);
--Let porcentaje_div =100;
--else 
--Let porcentaje_div =100;
--end if */
foreach	 
Select cod_producto,descripcion 
into v_cod_producto,v_descripcion 
from prddesc 
where cod_producto = v_cod_producto
end foreach

Insert Into emipode2(no_poliza,no_unidad, descripcion )
	Values(_no_poliza,'00001',v_descripcion);
	 
	 
	 
foreach
Select orden, cod_contrato, porc_partic_prima, porc_partic_suma 
into _li_orden, _li_cod_contrato, _li_porc_partic_prima, _li_porc_partic_suma 
     From rearucon Where cod_ruta = _cod_ruta 

 Insert  Into emigloco (no_poliza, no_endoso, orden, cod_contrato, porc_partic_prima,  porc_partic_suma, suma_asegurada, prima, cod_ruta)
                Values (_no_poliza, '00000', _li_orden, _li_cod_contrato, _li_porc_partic_prima, _li_porc_partic_suma,0.00, 0.00, _cod_ruta); 

end foreach


CALL sp_proe04(_no_poliza,'00001', _suma_asegurada, '001') returning  _error;
CALL sp_proe01(_no_poliza,'00001', '001') returning  _error;
CALL sp_proe03(_no_poliza,'001')returning  _error;
CALL sp_sis17(_no_poliza)returning  _error;
end
return 0,_no_poliza;	
end procedure;



