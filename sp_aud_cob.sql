drop procedure sp_aud_cob;
create procedure sp_aud_cob(a_periodo_desde char(7), a_periodo_hasta char(7))
	returning char(4),char(5),varchar(50),dec(16,2),dec(16,2),date;
	
BEGIN
define _no_poliza			char(10);
define _no_remesa			char(10);
define _n_agente            varchar(50);
define _cod_cobrador        char(3);
define _periodo				char(7);
define _cod_agente			char(5);
define _comi_boni      	    dec(16,2);
define _mto_prima_ac		dec(16,2);
define _mto_prima			dec(16,2);
define _porc_partic_prima   dec(9,6);
define _porc_partic_agt		dec(5,2);
define _renglon				integer;
define _cnt					integer;
define _fecha_pp_boni       date;
define v_filtros			char(255);

{set debug file to "sp_aud_cob.trc";
trace on;}

set isolation to dirty read;

drop table if exists temp_pri_cob;
create temp table temp_pri_cob(
cod_agente		char(5),
periodo 		char(7),
prima_neta		dec(16,2),
comi_cobranza	dec(16,2),
porc_boni       dec(9,2),
fecha_pp_boni	date) with no log;
create index id1_temp_pri_cob on temp_pri_cob(cod_agente);
create index id2_temp_pri_cob on temp_pri_cob(periodo);

--Sacar la prima neta cobrada
call sp_pro307aud('001','001',a_periodo_desde,a_periodo_hasta,'*','*','*','*','*','*') returning v_filtros; --crea temp_det

foreach
	select no_poliza,
		   prima_neta,
		   no_remesa,
		   renglon
	  into _no_poliza,
		   _mto_prima,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
	 
	select periodo
	  into _periodo
	  from cobremae
	 where no_remesa = _no_remesa;

    let _mto_prima_ac = 0.00;

	foreach
		select cod_agente,
			   porc_partic_agt
		  into _cod_agente,
			   _porc_partic_agt
		  from cobreagt
		 where no_remesa = _no_remesa
		   and renglon	 = _renglon
		   
		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;

		if _cod_cobrador <> '217' then --CORREDOR Remesa es distinto de consumo
		else
			continue foreach;
		end if
		let _mto_prima_ac = _mto_prima * (_porc_partic_agt / 100);
		
		select count(*)
		  into _cnt
		  from temp_pri_cob
		 where cod_agente   = _cod_agente
		   and periodo[1,4] = '2021';
		   
		if _cnt is null then
			let _cnt = 0;
        end if
		if _cnt = 0 then
			insert into temp_pri_cob
			values(	_cod_agente,
					_periodo,
					_mto_prima_ac,
					0,
					0,
					'01/01/1900');
		else
			update temp_pri_cob
			   set prima_neta   = prima_neta + _mto_prima_ac
			 where cod_agente   = _cod_agente
			   and periodo[1,4] = '2021';
		end if
		
	end foreach
END FOREACH

drop table temp_det;

--Sacar la prima neta cobrada 2022 hasta sept.
call sp_pro307aud('001','001','2022-01','2022-09','*','*','*','*','*','*') returning v_filtros; --crea temp_det

foreach
	select no_poliza,
		   prima_neta,
		   no_remesa,
		   renglon
	  into _no_poliza,
		   _mto_prima,
		   _no_remesa,
		   _renglon
	  from temp_det
	 where seleccionado = 1
	 
	select periodo
	  into _periodo
	  from cobremae
	 where no_remesa = _no_remesa;

    let _mto_prima_ac = 0.00;

	foreach
		select cod_agente,
			   porc_partic_agt
		  into _cod_agente,
			   _porc_partic_agt
		  from cobreagt
		 where no_remesa = _no_remesa
		   and renglon	 = _renglon
		   
		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;

		if _cod_cobrador <> '217' then --CORREDOR Remesa es distinto de consumo
		else
			continue foreach;
		end if
		
		let _mto_prima_ac = _mto_prima * (_porc_partic_agt / 100);
		
		select count(*)
		  into _cnt
		  from temp_pri_cob
		 where cod_agente   = _cod_agente
		   and periodo[1,4] = '2022';
		 
        if _cnt is null then
			let _cnt = 0;
        end if		
		
		select sum(comision)
		  into _comi_boni
		  from chqboni
		 where periodo >= '2022-01'
           and periodo <= '2022-09'
		   and cod_agente = _cod_agente;
		   
		if _comi_boni is null then
			let _comi_boni = 0;
		end if
		
		select min(fecha_genera)
		  into _fecha_pp_boni
		  from chqboni
		 where periodo >= '2022-01'
		   and periodo <= '2022-09'
		   and cod_agente = _cod_agente;
		
		if _fecha_pp_boni is null then
			let _fecha_pp_boni = '01/01/1900';
		end if
		   
		if _cnt = 0 then
			insert into temp_pri_cob
			values(	_cod_agente,
					_periodo,
					_mto_prima_ac,
					_comi_boni,
					0,
					_fecha_pp_boni);
		else
			update temp_pri_cob
			   set prima_neta    = prima_neta + _mto_prima_ac
			 where cod_agente    = _cod_agente
			   and periodo[1,4]  = '2022';
		
		end if
	end foreach
END FOREACH
drop table temp_det;
foreach
	select t.periodo[1,4],
	       a.nombre,
		   t.cod_agente,
		   sum(t.prima_neta),
		   sum(t.comi_cobranza),
		   t.fecha_pp_boni
	  into _periodo,
           _n_agente,
           _cod_agente,
           _mto_prima_ac,
           _comi_boni,
		   _fecha_pp_boni
	  from temp_pri_cob t, agtagent a
	 where t.cod_agente = a.cod_agente
	 group by t.cod_agente,t.periodo[1,4],a.nombre,t.fecha_pp_boni
	 order by t.periodo[1,4],a.nombre

	return _periodo,_cod_agente,_n_agente,_mto_prima_ac,_comi_boni,_fecha_pp_boni with resume;
end foreach
end		
end procedure;