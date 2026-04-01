-- Procedimiento para verificar las polizas de vida
-- Creado:     20/06/2025 - Autor Armando Moreno M.

drop procedure sp_verifica_vida;
create procedure sp_verifica_vida(a_periodo1 char(7),a_periodo2 char(7),a_nueva_ronov char(1) default "R")
returning smallint,char(10),char(10),char(100),char(20),date,date,char(1),char(2),date,integer,dec(16,2),dec(16,2),dec(16,2),dec(16,2);

define _n_asegurado			varchar(100);
define _edad	            integer;
define _no_poliza,_cod_asegurado        char(10); 
define _no_unidad           char(5);
define _valor,_fumador               smallint;
define _no_documento char(20);
define _vigencia_final,_fecha2,_fecha1,_fecha_aniv,_vig_ini date;
define _estatus_poliza smallint;
define _fumador_char char(2);
define _sexo char(1);
define _suma_aseg,_prima_neta,_porc_riesgo,_prima_acum dec(16,2);
define _porc_partic_prima,_porc_partic_suma     dec(9,6);
define _cnt,_cnt1    smallint;

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

create temp table tmp_pol(
poliza		char(20)
) with no log;

foreach
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where actualizado = 1
	   and cod_ramo = '019'
	   and periodo between a_periodo1 and a_periodo2
	   and nueva_renov = a_nueva_ronov
	  order by no_poliza 

	select vigencia_final,
	       prima_neta,
		   estatus_poliza,
		   no_documento,
		   vigencia_inic
	  into _vigencia_final,
	       _prima_neta,
		   _estatus_poliza,
		   _no_documento,
		   _vig_ini
	  from emipomae
	 where no_poliza = _no_poliza;
	 
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
		select count(*)
		  into _cnt1
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad
		   and porc_partic_suma = 50;
		   
		if _cnt1 is null then
			let _cnt1 = 0;
		end if
		if _cnt1 > 0 then
			insert into tmp_pol(poliza)
			values(_no_documento);
			continue foreach;
		end if
		   
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
		 
		let _edad = sp_sis78(_fecha_aniv,_vig_ini);
		
		return 1,_no_poliza,_cod_asegurado,_n_asegurado,_no_documento,_vig_ini,_vigencia_final,_sexo,_fumador_char,_fecha_aniv,_edad,_suma_aseg,_porc_riesgo,_prima_neta,_prima_acum with resume;
		insert into tmp_pol(poliza)
		values(_no_documento);
	end if
end foreach
foreach
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where actualizado = 1
	   and cod_ramo = '019'
   	   and periodo between a_periodo1 and a_periodo2
	   and nueva_renov = a_nueva_ronov
	  order by no_poliza 

	select vigencia_final,
	       prima_neta,
		   estatus_poliza,
		   no_documento,
		   vigencia_inic
	  into _vigencia_final,
	       _prima_neta,
		   _estatus_poliza,
		   _no_documento,
		   _vig_ini
	  from emipomae
	 where no_poliza = _no_poliza;
	 
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
	
	select nombre into _n_asegurado from cliclien
	where cod_cliente = _cod_asegurado;
	
	foreach
		select porc_partic_prima,
		       porc_partic_suma
		  into _porc_partic_prima,
		       _porc_partic_suma
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad

		if _porc_partic_prima = _porc_partic_suma then
			if _vig_ini < "01/07/2024" then
				continue foreach;
			end if
			select count(*)
			  into _cnt
			  from tmp_pol
			 where poliza = _no_documento;
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
				continue foreach;
			else
				insert into tmp_pol(poliza)
				values(_no_documento);
			end if
			--let _valor = sp_proe04_vida(_no_poliza,_no_unidad,"",_suma_aseg,'001');
			return 2,_no_poliza,_cod_asegurado,_n_asegurado,_no_documento,_vig_ini,_vigencia_final,"","","",0,_suma_aseg,0,0,0 with resume;
			exit foreach;
		end if
	end foreach	
end foreach
foreach
	select no_poliza
	  into _no_poliza
	  from emipomae
	 where actualizado = 1
	   and cod_ramo = '019'
	   and periodo between a_periodo1 and a_periodo2
	   and nueva_renov = a_nueva_ronov
	  order by no_poliza 

	select vigencia_final,
	       prima_neta,
		   estatus_poliza,
		   no_documento,
		   vigencia_inic
	  into _vigencia_final,
	       _prima_neta,
		   _estatus_poliza,
		   _no_documento,
		   _vig_ini
	  from emipomae
	 where no_poliza = _no_poliza;
	 
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
	select nombre into _n_asegurado from cliclien
		where cod_cliente = _cod_asegurado;
	foreach
		select porc_partic_prima,
		       porc_partic_suma
		  into _porc_partic_prima,
		       _porc_partic_suma
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = '00000'
		   and no_unidad = _no_unidad

		if _porc_partic_suma = 70 then
			if _vig_ini < "01/07/2024" then
				continue foreach;
			end if
			select count(*)
			  into _cnt
			  from tmp_pol
			 where poliza = _no_documento;
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
				continue foreach;
			end if
			--let _valor = sp_proe04_vida(_no_poliza,_no_unidad,"",_suma_aseg,'001');
			return 3,_no_poliza,_cod_asegurado,_n_asegurado,_no_documento,_vig_ini,_vigencia_final,"","","",0,_suma_aseg,0,0,0 with resume;
			exit foreach;
		end if
	end foreach	
end foreach
drop table tmp_pol;
end
end procedure;