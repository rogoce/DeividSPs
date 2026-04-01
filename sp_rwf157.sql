-- Procedimiento que hace calculos para la perdida total

-- Creado    : 12/11/2018 - Autor: Amado Perez  

drop procedure sp_rwf157;

create procedure sp_rwf157(a_no_reclamo char(10), a_vigencia date) 
returning smallint as depreciacion, 
          dec(16,2) as depre_anual,
		  dec(16,2) as depre_mensual,
		  dec(16,2) as depre_diario,
		  smallint as dias,
		  dec(16,2) as perdida,
		  smallint as li_error,
		  varchar(100) as mensaje;

define _no_poliza 	    char(10);
define _no_unidad 	    char(5);
define _no_motor        varchar(30);
define _suma_asegurada 	dec(16,2);
define _fecha_siniestro, _vigencia_inic, _vigencia_final date;
define _uso_auto        char(1);
define _ano_auto        integer;
define _anos            smallint;
define _porc_depre      smallint;
define _dias            smallint;
define _dep_anual, _dep_mensual, _dep_diario, _perdida dec(16,2);


--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

set isolation to dirty read;

select no_poliza,
       no_unidad,
	   suma_asegurada,
	   no_motor,
	   fecha_siniestro
  into _no_poliza,
       _no_unidad,
	   _suma_asegurada,
	   _no_motor,
       _fecha_siniestro	   
  from recrcmae
 where no_reclamo = a_no_reclamo;
  
select vigencia_inic,
       vigencia_final
  into _vigencia_inic,
       _vigencia_final
  from emipomae
 where no_poliza = _no_poliza;
 
 if a_vigencia < _vigencia_inic then
	return null, null, null, null, null, null, -1, "La fecha no puede ser menor a la vigencia inicial de la póliza";
 end if
   
 if a_vigencia > _vigencia_final then
	return null, null, null, null, null, null, -1, "La fecha no puede ser mayor a la vigencia final de la póliza";
 end if
 
 select uso_auto
   into _uso_auto
   from emiauto
  where no_poliza = _no_poliza
    and no_unidad = _no_unidad;
	
 if _no_motor is null or trim(_no_motor) = "" then
	foreach
		select no_motor,
		       uso_auto
		  into _no_motor,
		       _uso_auto
		  from emiauto
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   
		 exit foreach;		
	end foreach
 end if

 select ano_auto
   into _ano_auto
   from emivehic
  where no_motor = _no_motor;
  
 let _anos = year(a_vigencia) - _ano_auto;
 
 if _anos <= 0 or _anos = 1 then
	let _anos = 1;
 else
    let _anos = _anos + 1;
 end if
 
 select porc_depre
   into _porc_depre
   from emidepre
  where uso_auto = _uso_auto
    and ano_desde <= _anos
	and ano_hasta >= _anos;
	
 let _dias = a_vigencia - _fecha_siniestro;
 
 let _dep_anual = _suma_asegurada * _porc_depre / 100;
 
 let _dep_mensual = _dep_anual / 12;

 let _dep_diario = _dep_mensual / 30;

 let _perdida = _suma_asegurada + (_dep_diario * _dias);
  
return _porc_depre,
       _dep_anual, 
       _dep_mensual,
	   _dep_diario,
	   _dias,
	   _perdida,
	   0,
	   "Exitoso";

end procedure