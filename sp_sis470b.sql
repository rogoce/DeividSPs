-- Procedimiento que determina las variables para el descuento por siniestralidad

-- Tarifas Agosto 2015

--Proedure similar al sp_pro550 utilizado paras las pre-renovaciones y renovaciones automáticas

drop procedure sp_sis470b;
create procedure sp_sis470b(
a_no_documento		char(20)
) returning char(20), 
			smallint, 
			smallint, 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2), 
			dec(16,2),
			dec(16,2),
			smallint;

define _no_poliza			char(10);
define _fecha_proceso		date;
define _no_reclamo			char(10);
define _vigencia_inic		date;
define _vigencia_inic_ren  date;


define _cant_p				smallint;
define _cant_x_def			smallint;
define _cant_total			smallint;

define _no_sinis_ult		smallint;
define _no_sinis_his		smallint;
define _no_vigencias		dec(16,2);
define _no_sinis_pro		dec(16,2);

define _incurrido_bruto	dec(16,2);
define _prima_devengada	dec(16,2);
define _siniestralidad	dec(16,2);
define _incurrido			dec(16,2);
define _porc_descuento	dec(16,2);
define _tipo           smallint;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

let _fecha_proceso = today;

-- Numero de Siniestros Ultima Vigencia
--if a_no_documento = '0219-03929-09' then
--	SET DEBUG FILE TO "sp_pro550.trc";
--	TRACE ON;
--end if	
let _no_poliza = sp_sis21(a_no_documento);

select vigencia_final
  into _vigencia_inic_ren
  from emipomae
 where no_poliza = _no_poliza;


-- Perdidos
select count(*)
  into _cant_p
  from recrcmae
 where no_poliza 			= _no_poliza
   and estatus_audiencia 	in (0,8,6,12)
   and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
   and actualizado 		= 1;

{-- Por definir
select count(*)
  into _cant_x_def
  from recrcmae
 where no_poliza 			= _no_poliza
   and estatus_audiencia 	= 2
   and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
   and actualizado 		= 1;  
}

-- Por definir cambios 27-03-2017 Contar solo los que tienen incurrido >= 1
let _incurrido = 0.00;  
let _cant_x_def = 0; 
   
foreach
	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where no_poliza 			= _no_poliza
       and estatus_audiencia 	= 2
       and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
       and actualizado 		= 1

	let _incurrido = sp_rec255(_no_reclamo);
	
	if _incurrido >= 1 then
		let _cant_x_def = _cant_x_def + 1;
	end if	   
end foreach   

let _incurrido = 0.00;
--   
   
let _cant_total = _cant_p + _cant_x_def;

if _cant_total > 1 then
	let _no_sinis_ult = _cant_total;
else
	let _no_sinis_ult = _cant_p;
end if

-- Numero de Siniestros Historicos

-- Perdidos
select count(*)
  into _cant_p
  from recrcmae
 where no_documento 	 = a_no_documento
   and estatus_audiencia in (0,6,8,12)
   and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
   and actualizado 		= 1
   and year(fecha_siniestro) >= year(_vigencia_inic_ren) - 3;

{-- Por definir
select count(*)
  into _cant_x_def
  from recrcmae
 where no_documento 		= a_no_documento
   and estatus_audiencia 	= 2
   and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
   and actualizado 		= 1;  
}

-- Por definir cambios 27-03-2017 Contar solo los que tienen incurrido >= 1
let _incurrido = 0.00;  
let _cant_x_def = 0; 
   
foreach
	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where no_documento 		= a_no_documento
       and estatus_audiencia 	= 2
       and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
       and actualizado 		= 1
       and year(fecha_siniestro) >= year(_vigencia_inic_ren) - 3

	let _incurrido = sp_rec255(_no_reclamo);
	
	if _incurrido >= 1 then
		let _cant_x_def = _cant_x_def + 1;
	end if	   
end foreach   

let _incurrido = 0.00;
--   


let _cant_total = _cant_p + _cant_x_def;

if _cant_total >= 1 then
	let _no_sinis_his = _cant_total;
else
	let _no_sinis_his = _cant_p;
end if

-- Numero de Vigencias

select min(vigencia_inic)
  into _vigencia_inic
  from emipomae
 where no_documento 	= a_no_documento
   and actualizado		= 1; 
   
let _no_vigencias 	= (_fecha_proceso - _vigencia_inic_ren) / 365;
--let _no_vigencias 	= (_fecha_proceso - _vigencia_inic) / 365;

if _no_vigencias <= 0 then -- Amado 4-5-2017 esta dando error de division por cero
	let _no_vigencias = 1;
end if

let _no_sinis_pro	= _no_sinis_his / _no_vigencias;

-- Incurrido Bruto Historico

if _no_sinis_his = 0 then

	let _incurrido_bruto = 0;

elif _no_sinis_his = 1 then

	let _incurrido_bruto = 0;
	
	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where no_documento 		= a_no_documento
	    and estatus_audiencia in (0,6,8,12)
	    and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
	    and actualizado 		= 1
        and year(fecha_siniestro) >= year(_vigencia_inic_ren) - 3

		let _incurrido 		= sp_rec255(_no_reclamo);
		let _incurrido_bruto	= _incurrido_bruto + _incurrido;
		
	end foreach

else
	
	let _incurrido_bruto = 0;
	
	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where no_documento 		= a_no_documento
	    and estatus_audiencia in (0,6,8,12)
	    and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
	    and actualizado 		= 1
        and year(fecha_siniestro) >= year(_vigencia_inic_ren) - 3

		let _incurrido 		= sp_rec255(_no_reclamo);
		let _incurrido_bruto	= _incurrido_bruto + _incurrido;
		
	end foreach

	foreach
	 select no_reclamo
	   into _no_reclamo
       from recrcmae
      where no_documento 		= a_no_documento
        and estatus_audiencia = 2
        and cod_evento  		in ('016','002','003','004','006','007','011','050','059','138')	      
        and actualizado 		= 1  
        and year(fecha_siniestro) >= year(_vigencia_inic_ren) - 3
		
		let _incurrido 		= sp_rec255(_no_reclamo);
		let _incurrido_bruto	= _incurrido_bruto + _incurrido;

	end foreach

end if

-- Calculo de la Prima Devengada

call sp_dev03(a_no_documento, _fecha_proceso) returning _error, _error_desc;

select sum(prima_devengada)
  into _prima_devengada
  from tmp_prima_devengada;
  
drop table tmp_prima_devengada;

-- Siniestralidad
if _incurrido_bruto = 0 and _prima_devengada = 0 then
	let _siniestralidad = 0;
elif _prima_devengada = 0 then
	let _siniestralidad = 100;
else
	let _siniestralidad = (_incurrido_bruto / _prima_devengada) * 100;	
end if

call sp_pro549(_no_sinis_ult, _no_sinis_pro, _siniestralidad) returning _porc_descuento, _tipo;

return a_no_documento, 
        _no_sinis_ult, 
		_no_sinis_his, 
		_no_vigencias, 
		_no_sinis_pro, 
		_incurrido_bruto, 
		_prima_devengada, 
		_siniestralidad,
		_porc_descuento,
		_tipo;
		   
end procedure

