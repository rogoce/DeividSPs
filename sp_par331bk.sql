--- Procedimiento que actualiza las polizas nuevas y renovadas para el presupuesto de ventas 

-- Creado    : 08/02/2013 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par331;

create procedure "informix".sp_par331()
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
no_pol_renov_ap     integer		default 0
) with no log;
CREATE INDEX idx1_tmp_persisbk ON tmp_persisbk(no_documento);

let _fecha_ano2 = year(today);
let _fecha_ano1 = _fecha_ano2 - 1;
let _periodo = '';
let _no_pol_reno = 0;

--let _ano = 2013;

--for _ano = _fecha_ano1 to _fecha_ano2

	--for _mes = 1 to 12
		
/*		if _mes < 10 then
			let _periodo = _ano || "-0" || _mes;
		else
			let _periodo = _ano || "-" || _mes;
		end if 
*/
		-- Limpiar el contador

		update deivid_bo:preventas
		   set polizas_nuevas        = 0,
		       polizas_nuevas_persis = 0,
			   polizas_renov_persis  = 0
		 where periodo   >= '2015-01'
		   and periodo   <= '2015-12';

		-- Polizas Nuevas

/*		
		let _fecha_ini = MDY(_mes, 1, _ano);
		let _fecha_fin = sp_sis36(_periodo);
*/
-- año Pasado	

	    let _fecha_ini = '01/01/2014';
		let _fecha_fin = '31/12/2014';
		
		call sp_bo077(_fecha_ini, _fecha_fin) returning _error, _error_desc;

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
	    let _fecha_ini = '01/01/2015';
		let _fecha_fin = '31/12/2015';
		
		call sp_bo077(_fecha_ini, _fecha_fin) returning _error, _error_desc;

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
		
	-- año pasado
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
			
			let _no_pol_tot_ap = _no_pol_nuebk + _no_pol_renobk;	
		
			if _no_pol_reno > _no_pol_tot_ap then
				let _no_pol_nue = 1;
			end if
			
/*			if _no_pol_reno = 1 then
				if _no_pol_nuebk = 1 then
					let _no_pol_nue = 1;
				end if	
			end if
*/		
			let _no_poliza = sp_sis21(_no_documento);

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

			select cod_vendedor
			  into _cod_vendedor
			  from agtagent
			 where cod_agente = _cod_agente;
			 
           select vigencia_inic
             into _vigencia_inic		
             from endedmae
            where cod_compania  = "001"
              and actualizado   = 1
  	          and cod_endomov   = "011"
  	          and no_poliza    = _no_poliza;
			  
			  call sp_sis39(_vigencia_inic) returning _periodo;
			  
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

		end foreach

		drop table tmp_persis;
		drop table tmp_persisbk;

--	end for

--end for

end

return 0, "Actualizacion Exitosa";

end procedure