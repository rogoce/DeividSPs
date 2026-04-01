-- Procedimiento que calcula la perdida total

-- Creado    : 13/07/2018 - Autor: Amado Perez  

drop procedure sp_rwf146;

create procedure sp_rwf146(a_no_reclamo char(10), a_salvamento dec(16,2) default 0.00, a_depreciacion dec(16,2) default 0.00) 
returning dec(16,2) as perdida, dec(16,2) as deducible, dec(16,2) as salvamento, dec(16,2) as prima_pendiente, dec(16,2) as total_pagar;

define _no_poliza       char(10);
define _no_documento    char(20);
define _no_unidad       char(5);
define _no_motor        char(30);
define _suma_asegurada  dec(16,2);
define _fecha_siniestro date;
define _vigencia_inic   date;
define _uso_auto        char(1);
define _ano_auto        smallint;
define _resultado       smallint;
define _porc_depre      smallint;
define _depre_anual     dec(16,2);
define _dias            smallint;
define _depre_mensual   dec(16,2);
define _depre_diaria    dec(16,2);
define _perdida         dec(16,2);
define _saldo			dec(16,2);
define _cod_cobertura	char(5);
define _deducible     	dec(16,2);
define _a_pagar         dec(16,2);
define _salvamento      dec(16,2);
define _deducible_pagado dec(16,2);

--return 0, "Actualizacion Exitosa";
--SET DEBUG FILE TO "sp_rwf146.trc"; 
--trace on;

select no_poliza, 
       no_documento,
       no_unidad,
	   no_motor,
	   suma_asegurada,
	   fecha_siniestro
  into _no_poliza,
       _no_documento,
	   _no_unidad,
	   _no_motor,
	   _suma_asegurada,
	   _fecha_siniestro
  from recrcmae
 where no_reclamo = a_no_reclamo;
 
 let _saldo = sp_rwf100(_no_documento);
 
 call sp_rwf101(a_no_reclamo) returning _cod_cobertura, _deducible;
 
 let _deducible_pagado = sp_rec283(a_no_reclamo);
 
 let _deducible = _deducible + _deducible_pagado;
 
 { SELECT sum(a.monto)
   INTO _salvamento
   FROM rectrcon a, rectrmae b
  WHERE a.no_tranrec = b.no_tranrec
    AND b.no_reclamo = a_no_reclamo
	AND a.cod_concepto = '019';

 if _salvamento is null then
	let _salvamento = 0.00;
 end if
} 
 select vigencia_inic
   into _vigencia_inic
   from emipomae
  where no_poliza = _no_poliza;
  
 let _uso_auto = null;
 
 select uso_auto
   into _uso_auto
   from emiauto
  where no_poliza = _no_poliza
    and no_unidad = _no_unidad;
	
 if _uso_auto is null or trim(_uso_auto) = "" then
	foreach
		select uso_auto
		  into _uso_auto
		  from endmoaut
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		exit foreach;
	end foreach
 end if
 
 select ano_auto
   into _ano_auto
   from emivehic
  where no_motor = _no_motor;
  
 let _resultado = year(_vigencia_inic) - _ano_auto;
 
 select porc_depre
   into _porc_depre
   from emidepre
  where uso_auto = _uso_auto
    and ano_desde <= _resultado
	and ano_hasta >= _resultado;
	
 if a_depreciacion <> 0.00 then
	let _porc_depre = a_depreciacion;
 end if
	
 let _depre_anual = _suma_asegurada * _porc_depre / 100;
 
 let _depre_anual = ROUND(_depre_anual,2);

 let _dias = _fecha_siniestro - _vigencia_inic;
 
 let _dias = _dias * (-1);
 
 let _depre_mensual = _depre_anual / 12;
 
 let _depre_mensual = ROUND(_depre_mensual,2);
 
 let _depre_diaria = _depre_mensual / 30;
 
 let _depre_diaria = ROUND(_depre_diaria,2);
 
 let _perdida = _suma_asegurada + (_depre_diaria * _dias);
 
 let _perdida = ROUND(_perdida, 2);
 
 let _a_pagar = _perdida - (_deducible + a_salvamento + _saldo);
 
 return _perdida, _deducible, a_salvamento, _saldo, _a_pagar;
  
end procedure