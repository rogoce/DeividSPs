drop procedure sp_aud_cob1;
create procedure sp_aud_cob1()
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

{let _periodo = '2021';
foreach
	select cod_agente,
	       sum(moro_045)
	  into _cod_agente,
	       _mto_prima
		   from chqboni
	 where periodo >= '2021-01'
       and periodo <= '2021-12'
  group by cod_agente
  order by cod_agente

	select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	if _cod_cobrador <> '217' then --CORREDOR Remesa es distinto de consumo
	else
		continue foreach;
	end if
		
	select count(*)
	  into _cnt
	  from temp_pri_cob
	 where cod_agente   = _cod_agente;
	   
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then
		insert into temp_pri_cob
		values(	_cod_agente,
				_periodo,
				_mto_prima,
				0,
				0,
				'01/01/1900');
	else
		update temp_pri_cob
		   set prima_neta   = prima_neta + _mto_prima
		 where cod_agente   = _cod_agente;
	end if
	
END FOREACH
}

let _periodo = '2021';
foreach
	select cod_agente,
	       sum(moro_045),
		   sum(comision)
	  into _cod_agente,
	       _mto_prima,
		   _comi_boni
		   from chqboni
	 where periodo >= '2021-01'
       and periodo <= '2021-12'
  group by cod_agente
  order by cod_agente

	select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	if _cod_cobrador <> '217' then --CORREDOR Remesa es distinto de consumo
	else
		continue foreach;
	end if
	   
	select count(*)
	  into _cnt
	  from temp_pri_cob
	 where cod_agente   = _cod_agente
	   and periodo[1,4] = '2021';
	 
	if _cnt is null then
		let _cnt = 0;
	end if
		
	select min(fecha_genera)
	  into _fecha_pp_boni
	  from chqboni
	 where periodo >= '2021-01'
	   and periodo <= '2021-12'
	   and cod_agente = _cod_agente;
	
	if _fecha_pp_boni is null then
		let _fecha_pp_boni = '01/01/1900';
	end if

	if _cnt = 0 then
		insert into temp_pri_cob
		values(	_cod_agente,
				_periodo,
				_mto_prima,
				_comi_boni,
				0,
				_fecha_pp_boni);
	else
		update temp_pri_cob
		   set prima_neta    = prima_neta + _mto_prima
		 where cod_agente    = _cod_agente
		   and periodo[1,4]  = '2021';
	
	end if
END FOREACH
--corredores que no han llegado
{foreach
	select cod_agente,
	       prima_cobrada
	  into _cod_agente,
	       _mto_prima
	  from chqboagt
	 where retroactivo = 0
	 order by prima_cobrada desc

	select count(*)
	  into _cnt
	  from temp_pri_cob
	 where cod_agente   = _cod_agente
	   and periodo[1,4] = '2022';
	   
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
		continue foreach;
	end if
	
	select cod_cobrador
	  into _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	if _cod_cobrador <> '217' then --CORREDOR Remesa es distinto de consumo
	else
		continue foreach;
	end if
	   
	if _cnt = 0 then
		insert into temp_pri_cob
		values(	_cod_agente,
				_periodo,
				_mto_prima,
				0,
				0,
				'01/01/1900');
	end if
END FOREACH
}
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