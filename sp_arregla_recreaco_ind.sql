-- Procedimiento para arreglar RECREACO/EMIREACO
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco_ind;
create procedure sp_arregla_recreaco_ind(a_no_reclamo char(10))
returning	integer;

define _error_desc						char(100);
define _error,_no_cambio,_cnt		        integer;
define _error_isam	        integer;
define _no_tranrec,_no_poliza        char(10); 
define _cod_ruta,_no_unidad           char(5);
define _cantidad,_flag,_flag2,_renglon,_valor            smallint;
define _no_documento char(20);
define _porc_suma,_porcentaje  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic,_fecha_actual date;
define _mensaje 			varchar(250);

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _fecha_actual = current;
let _cnt = 0;

select no_poliza,
       no_unidad
  into _no_poliza,
       _no_unidad
  from recrcmae
 where no_reclamo = a_no_reclamo;

select cod_ramo,
       vigencia_inic,
       vigencia_final
  into _cod_ramo,
       _vigencia_inic,
       _vigencia_final
  from emipomae
 where no_poliza = _no_poliza;

--SE VERIFICA SI EL RECLAMO TIENE LOS % DE ACUERDO A LA RUTA ACTIVA DEL RAMO Y VIGENCIA
select count(*)
  into _cnt
  from recreaco
 where no_reclamo = a_no_reclamo
   and porc_partic_suma in(
   select distinct porc_partic_prima from rearucon
    where cod_ruta in(
   select cod_ruta from rearumae
    where cod_ramo = _cod_ramo
      and activo = 1
      and _fecha_actual between vig_inic and vig_final));
	  
if _cnt is null then
	let _cnt = 0;
end if

if _cnt > 0 then	--RECREACO tiene contratos y porcentajes correctos.
	return 0;
end if
--SE SACA EL PORCENTAJE DE LA RUTA PARA PODER COMPARAR
foreach
   select distinct porc_partic_prima
	 into _porcentaje
	 from rearucon
	where cod_ruta in(
   select cod_ruta from rearumae
	where cod_ramo = _cod_ramo
	  and activo = 1
	  and _fecha_actual between vig_inic and vig_final)
		  
	exit foreach;
end foreach
--SE RECORRE TRANSACCIONES DEL RECLAMO, EN BUSCA DE ALGUNA CON RECTRREA CORRECTO PARA USAR DE MOLDE.
let _flag = 0;
foreach
	select no_tranrec
	  into _no_tranrec
	  from rectrmae
	 where no_reclamo = a_no_reclamo
	   and actualizado = 1
	   and periodo >= '2024-01'
	   
	foreach
		select porc_partic_suma
		  into _porc_suma
		  from rectrrea
		 where no_tranrec = _no_tranrec
		 
		if _porc_suma in(_porcentaje) then
			let _flag = 1;
			exit foreach;
		else
			continue foreach;
		end if
	end foreach
	
	if _flag = 1 then	--SE CREA RECREACO, A PARTIR DEL MOLDE RECTRREA
		select * from rectrrea
		where no_tranrec = _no_tranrec into temp prueba_rec;
		
		delete from recreaco
		where no_reclamo = a_no_reclamo;
		
		update prueba_rec
		   set no_tranrec = a_no_reclamo;
		   
		insert into recreaco(no_reclamo,orden,cod_contrato,porc_partic_suma,porc_partic_prima,subir_bo,cod_cober_reas)
		select no_tranrec,orden,cod_contrato,porc_partic_suma,porc_partic_prima,subir_bo,cod_cober_reas
		  from prueba_rec;
		
		drop table prueba_rec;
		let _valor = sp_arregla_emireaco(a_no_reclamo);	--SE INSERTA UN no_cambio con los contratos y % proveniente de la ruta activa del ramo 2024
		exit foreach;
	end if
end foreach
if _flag = 0 then	--ninguna N/T tenia contrato 5/95, procedemos a buscar emireaco
	 
	let _no_cambio = 0;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;
		
	let _flag2 = 0;
	foreach
		select porc_partic_suma
		  into _porc_suma
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio
		 
		if _porc_suma in(_porcentaje) then
			let _flag2 = 1;
			call sp_sis18am(a_no_reclamo) returning _error,_mensaje;
			exit foreach;
		end if
	end foreach
	if _flag2 = 0 then	--Emireaco no tiene 5/95, hay que insertarlo.
		let _valor = sp_arregla_emireaco(a_no_reclamo);	--inserta un no_cambio con los contratos y % proveniente de la ruta activa del ramo 2024
		call sp_sis18(a_no_reclamo) returning _error,_mensaje;
	end if
end if
return 0;
end
end procedure;