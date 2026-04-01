-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_proe95;
create procedure sp_proe95(a_periodo1 char(7),a_periodo2 char(7))
returning char(10),char(100),char(20),date,char(1),char(2),date,integer,dec(16,2),dec(16,2),dec(16,2),dec(16,2);

define _n_asegurado			varchar(100);
define _edad	            integer;
define _no_poliza,_cod_asegurado        char(10); 
define _no_unidad           char(5);
define _valor,_fumador               smallint;
define _no_documento char(20);
define _vigencia_final,_fecha2,_fecha1,_fecha_aniv date;
define _estatus_poliza smallint;
define _fumador_char char(2);
define _sexo char(1);
define _suma_aseg,_prima_neta,_porc_riesgo,_prima_acum dec(16,2);

--set debug file to "sp_arregla_emireaco_vida1.trc";
--trace on;

begin

set isolation to dirty read;

let _suma_aseg = 0.00;
let _prima_neta = 0.00;
let _porc_riesgo = 0.00;
let _prima_acum = 0.00;
let _fumador_char = "";

let _fecha1 = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]);
let _fecha2 = sp_sis36(a_periodo1);

foreach
	select distinct no_documento
	  into _no_documento
	  from emipomae
	 where actualizado = 1
	   and cod_ramo = '019'
	   and vigencia_final >= _fecha1
	   and vigencia_final <= _fecha2
	   
	let _no_poliza = sp_sis21(_no_documento);
	
	select vigencia_final,
	       prima_neta,
		   estatus_poliza
	  into _vigencia_final,
	       _prima_neta,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _estatus_poliza in(2,4) then
		continue foreach;
	end if	
	
	foreach
		select no_unidad,
		       suma_asegurada,
			   cod_asegurado
		  into _no_unidad,
		       _suma_aseg,
			   _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	call sp_proe04_vida2(_no_poliza,_no_unidad,'',_suma_aseg,'001') returning _valor,_porc_riesgo,_prima_acum;
	
	if _valor = 0 then
	else
		select fecha_aniversario,
		       sexo,
		       fumador
		  into _fecha_aniv,
		       _sexo,
		       _fumador
		  from cliclien
		 where cod_cliente = _cod_asegurado;
		 
		select nombre into _n_asegurado from cliclien
		where cod_cliente = _cod_asegurado;
		 
		if _fumador = 1 then
			let _fumador_char = 'SI';
		elif _fumador = 0 then
			let _fumador_char = 'NO';
		end if
		 
		let _edad = sp_sis78(_fecha_aniv,_vigencia_final);
		
		return _cod_asegurado,_n_asegurado,_no_documento,_vigencia_final,_sexo,_fumador_char,_fecha_aniv,_edad,_suma_aseg,_porc_riesgo,_prima_neta,_prima_acum with resume;
	end if
end foreach
end
end procedure;