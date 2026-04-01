--- Procedimiento que actualiza las polizas nuevas y renovadas para el presupuesto de ventas 

-- Creado    : 08/02/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par331bkf;

create procedure "informix".sp_par331bkf()
returning integer,
          char(50);

-- Actualizar Polizas Nuevas

define _ano				integer;
define _mes				smallint;
define _periodo			char(7);
define _fecha_ini		date;
define _fecha_fin		date;
define _vigencia_inic   date;
define _fecha_ano1		integer;
define _fecha_ano2		integer;

define _no_pol_nue		integer;
define _no_pol_nue_per	integer;
define _no_pol_ren_per	integer;

define _no_poliza		char(10);
define _no_documento	char(20);
define _cod_agente		char(5);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);

define _error			integer;
define _error_isam		integer;
define _no_pol_tot_ap   integer;
define _no_pol_reno     integer;
define _no_pol_nuebk    integer;
define _no_pol_renobk   integer;
define _cantidad        integer;
define _periodo_ini     char(7);
define _periodo_fin     char(7);
define _anobk           integer;
define _periodo_ap      char(7);
define _emi_periodo		char(7);
define _cob_periodo		char(7);
define _fecha_cierre	date;
define _cod_coasegur	char(3);

define _per_ini_aa		char(7);
define _per_fin_aa		char(7);
define _per_ini_ap		char(7);
define _per_fin_ap		char(7);

define _fecha_ini_ap	date;
define _fecha_fin_ap	date;
define _fecha_ini_aa	date;
define _fecha_fin_aa	date;
define _cnt             integer;

define _error_desc		char(50);

--set debug file to "sp_par331.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

create temp table tmp_persisbk(
no_documento		char(20),
no_pol_nueva		integer		default 0,
no_pol_nueva_per	integer		default 0,
no_pol_renov		integer 	default 0,
no_pol_renov_per	integer		default 0,
periodo             char(7),
no_pol_nueva_ap	    integer		default 0,        
no_pol_renov_ap     integer		default 0,
cod_agente          char(5)
) with no log;
CREATE INDEX idx1_tmp_persisbk ON tmp_persisbk(no_documento);

-- Periodos de Comparacion

select par_periodo_ant,
	   par_periodo_act,
	   par_ase_lider,
	   fecha_cierre
  into _emi_periodo,
       _cob_periodo,
	   _cod_coasegur,
	   _fecha_cierre
  from parparam;  

-- Año Actual

if (today - _fecha_cierre) > 1 then
	let _per_fin_aa	= _cob_periodo;
else
	let _per_fin_aa	= _emi_periodo;
end if

--Correr un periodo especifico 
--let _per_fin_aa = "2015-04"; --***********************************************************************************************************************************  

let _ano          = _per_fin_aa[1,4];
let _per_ini_aa   = _ano || "-01";

let _fecha_ini_aa = MDY(1, 1, _ano);
let _fecha_fin_aa = sp_sis36(_per_fin_aa);

-- Año Pasado

let _ano = _ano - 1;
let _per_fin_ap   = _ano || _per_fin_aa[5,7];
let _per_ini_ap   = _ano || "-01";

let _fecha_ini_ap = MDY(1, 1, _ano);
let _fecha_fin_ap = sp_sis36(_per_fin_ap);

let _periodo = '';
let _no_pol_reno = 0;

let _anobk = year(today);
let _periodo_ini = _anobk || "-0" || 1;
let _periodo_fin = _anobk || "-"  || 12;

-- Limpiar el contador periodo actual

update deivid_bo:preventas
   set polizas_nuevas        = 0,
	   polizas_nuevas_persis = 0,
	   polizas_renov_persis  = 0
 where periodo   >= _periodo_ini
   and periodo   <= _periodo_fin;

-- Limpiar el contador periodo pasado

update deivid_bo:preventas
   set polizas_nuevas        = 0,
	   polizas_nuevas_persis = 0,
	   polizas_renov_persis  = 0
 where periodo   >= _per_ini_ap
   and periodo   <= _per_fin_ap;   
   
-- Polizas Nuevas
-- año Pasado	

--let _fecha_ini_ap = '01/01/2014';
--let _fecha_fin_ap = '30/04/2014';

call sp_bo077(_fecha_ini_ap, _fecha_fin_ap) returning _error, _error_desc;

if _error <> 0 then 
	return _error, _error_desc;
end if

-- Sumatoria
foreach
 select no_documento,
		sum(no_pol_nueva),
		sum(no_pol_nueva_per),
		sum(no_pol_renov_per),
		sum(no_pol_renov)
   into _no_documento,
		_no_pol_nue,
		_no_pol_nue_per,
		_no_pol_ren_per,
		_no_pol_reno
   from tmp_persis
  group by no_documento

		insert into tmp_persisbk(
		no_documento, 
		no_pol_nueva_ap,
		no_pol_nueva_per,
		no_pol_renov_per,				
		no_pol_renov_ap
		)
		values(
		_no_documento, 
		_no_pol_nue,
		_no_pol_nue_per,
		_no_pol_ren_per,
		_no_pol_reno
		);

end foreach

drop table tmp_persis;
	
-- año actual
--let _fecha_ini_aa = '01/01/2015';
--let _fecha_fin_aa = '30/04/2015';
	
call sp_bo077(_fecha_ini_aa, _fecha_fin_aa) returning _error, _error_desc;

if _error <> 0 then 
	return _error, _error_desc;
end if
		
-- Sumatoria
foreach
 select no_documento,
		sum(no_pol_nueva),
		sum(no_pol_nueva_per),
		sum(no_pol_renov_per),
		sum(no_pol_renov)
   into _no_documento,
		_no_pol_nue,
		_no_pol_nue_per,
		_no_pol_ren_per,
		_no_pol_reno
   from tmp_persis
  group by no_documento

		insert into tmp_persisbk(
		no_documento, 
		no_pol_nueva,
		no_pol_nueva_per,
		no_pol_renov_per,				
		no_pol_renov
		)
		values(
		_no_documento, 
		_no_pol_nue,
		_no_pol_nue_per,
		_no_pol_ren_per,
		_no_pol_reno
		);
end foreach

drop table tmp_persis;
		
-- aÃ±o pasado
foreach
	select no_documento,
		sum(no_pol_nueva),
		sum(no_pol_nueva_per),
		sum(no_pol_renov_per),
		sum(no_pol_renov),
		sum(no_pol_nueva_ap),
		sum(no_pol_renov_ap)
	into _no_documento,
		_no_pol_nue,
		_no_pol_nue_per,
		_no_pol_ren_per,
		_no_pol_reno,
		_no_pol_nuebk,
		_no_pol_renobk
	from tmp_persisbk
	group by no_documento

	if _no_pol_nue > 1 then
		let _no_pol_nue = 1;
	end if

	if _no_pol_nuebk > 1 then
		let _no_pol_nuebk = 1;
	end if

	if _no_pol_renobk > 1 then
		let _no_pol_renobk = 1;
	end if

	let _no_pol_tot_ap = _no_pol_nuebk + _no_pol_renobk;

	if _no_pol_tot_ap > 1 then
		let _no_pol_tot_ap = 1;
		let _no_pol_renobk = 0;
	end if

	if _no_pol_reno > 1 then
		let _no_pol_reno = 1;
	end if

	if _no_pol_nue_per > 1 then
		let _no_pol_nue_per = 1;
	end if

	if _no_pol_ren_per > 1 then
		let _no_pol_ren_per = 1;
	end if

	if _no_pol_nue_per = 1 and 
	   _no_pol_ren_per = 1 then
		let _no_pol_nue_per = 0;
	end if

	if _no_pol_reno > _no_pol_tot_ap then
		let _no_pol_nue = 1;
	end if

	
-- Año Actual	
	--let _no_poliza = sp_sis21(_no_documento);
	foreach
	  select no_poliza
	    into _no_poliza 
		from emipomae
	   where cod_compania  = "001"
		 and actualizado   = 1
		 and vigencia_inic >= _fecha_ini_aa 
		 and vigencia_inic <= _fecha_fin_aa
		 and no_documento  = _no_documento
	order by no_poliza desc
		exit foreach;
	end foreach

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	  order by porc_partic_agt desc
		exit foreach;
	end foreach

	update tmp_persisbk
	   set cod_agente = _cod_agente
	 where no_documento = _no_documento;

	select cod_vendedor
	  into _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;
		
	if 	_cod_ramo <> '018' then
			   select vigencia_inic
				 into _vigencia_inic		
				 from endedmae
				where cod_compania  = "001"
				  and actualizado   = 1
				  and cod_endomov   = "011"
				  and no_poliza     = _no_poliza;
				  
				call sp_sis39(_vigencia_inic) returning _periodo;
	else

			--call sp_sis39(_fecha_ini_aa) returning _periodo_ini;
			--call sp_sis39(_fecha_fin_aa) returning _periodo_fin;
			
			{ select	max(periodo)
			   into _periodo
			   from endedmae
			  where  periodo    >= _periodo_ini
			    and periodo     <= _periodo_fin
	            and actualizado = 1
	            and cod_endomov = "014"
			    and no_poliza   = _no_poliza;}

			 
			   select vigencia_inic
				 into _vigencia_inic		
				 from endedmae
				where cod_compania  = "001"
				  and actualizado   = 1
				  and cod_endomov   = "011"
				  and no_poliza     = _no_poliza;

			call sp_sis39(_vigencia_inic) returning _periodo;
		/*	if _periodo < _per_fin_aa then
				let _periodo = _per_fin_aa;
			end if	*/
	end if
		
	if _periodo is null then
		continue foreach;
	end if
	
	select count(*)
	  into _cantidad
	  from deivid_bo:preventas
	 where cod_vendedor = _cod_vendedor
	   and cod_agente   = _cod_agente
	   and cod_ramo     = _cod_ramo
	   and periodo		= _periodo;    
		
	if _cantidad = 0 then
		insert into deivid_bo:preventas
		values (_cod_vendedor, _cod_agente, _cod_ramo, _periodo, 0, 0, 0, 0,0,0,0);
	end if		  
				  
	update deivid_bo:preventas
	   set polizas_nuevas        = polizas_nuevas        + _no_pol_nue,
		   polizas_nuevas_persis = polizas_nuevas_persis + _no_pol_nue_per,
		   polizas_renov_persis	 = polizas_renov_persis	 + _no_pol_ren_per
	 where cod_vendedor          = _cod_vendedor
	   and cod_agente            = _cod_agente
	   and cod_ramo              = _cod_ramo
	   and periodo               = _periodo;

	   
-- Año Pasado
		--let _no_poliza = sp_sis21(_no_documento);
	foreach
	  select no_poliza
	    into _no_poliza 
		from emipomae
	   where cod_compania  = "001"
		 and actualizado   = 1
		 and vigencia_inic >= _fecha_ini_ap
		 and vigencia_inic <= _fecha_fin_ap
		 and no_documento  = _no_documento
	order by no_poliza desc
		exit foreach;
	end foreach
	
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
	  order by porc_partic_agt desc
		exit foreach;
	end foreach

/*	update tmp_persisbk
	   set cod_agente = _cod_agente
	 where no_documento = _no_documento;
*/
	select cod_vendedor
	  into _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;
		
	if 	_cod_ramo <> '018' then
			   select vigencia_inic
				 into _vigencia_inic		
				 from endedmae
				where cod_compania  = "001"
				  and actualizado   = 1
				  and cod_endomov   = "011"
				  and no_poliza     = _no_poliza;
				  
				call sp_sis39(_vigencia_inic) returning _periodo;
	else

			   select vigencia_inic
				 into _vigencia_inic		
				 from endedmae
				where cod_compania  = "001"
				  and actualizado   = 1
				  and cod_endomov   = "011"
				  and no_poliza     = _no_poliza;
			call sp_sis39(_vigencia_inic) returning _periodo;
	end if
		
	if _periodo is null then
		continue foreach;
	end if
	
	select count(*)
	  into _cantidad
	  from deivid_bo:preventas
	 where cod_vendedor = _cod_vendedor
	   and cod_agente   = _cod_agente
	   and cod_ramo     = _cod_ramo
	   and periodo		= _periodo;    
		
	if _cantidad = 0 then
		insert into deivid_bo:preventas
		values (_cod_vendedor, _cod_agente, _cod_ramo, _periodo, 0, 0, 0, 0,0,0,0);
	end if		  
				  
	update deivid_bo:preventas
	   set polizas_nuevas        = polizas_nuevas        + _no_pol_nuebk,
		   polizas_nuevas_persis = polizas_nuevas_persis + _no_pol_nue_per,
		   polizas_renov_persis	 = polizas_renov_persis	 + _no_pol_ren_per
	 where cod_vendedor          = _cod_vendedor
	   and cod_agente            = _cod_agente
	   and cod_ramo              = _cod_ramo
	   and periodo               = _periodo;
   
end foreach

drop table tmp_persisbk;

end
return 0, "Actualizacion Exitosa";
end procedure