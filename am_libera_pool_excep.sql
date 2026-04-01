-- Pool Excepciones ---> Pool Manual

-- Creado    : 18/03/2025 - Autor:Armando Moreno M.

DROP PROCEDURE am_libera_pool_excep;
CREATE PROCEDURE am_libera_pool_excep()
returning varchar(50),	 --_n_corredor,
		  char(10),		 --_no_poliza,
		  char(8),		 --_user_added,   
		  char(3),       --_cod_no_renov,   
		  char(20),		 --_no_documento,   
		  smallint,		 --_renovar,   
		  smallint,		 --_no_renovar,   
		  date,			 --_fecha_selec,   
		  date,			 --_vigencia_inic,   
		  date,			 --_vigencia_final,   
		  dec(16,2),	 --_saldo,   
		  smallint,		 --_cant_reclamos,   
		  char(10),		 --_no_factura,   
		  decimal(16,2), --_incurrido,   
		  decimal(16,2), --_pagos,   
		  decimal(5,2),	 --_porc_depreciacion,
		  char(5),	   	 --_cod_agente,
		  varchar(100),  --_n_cliente,
		  decimal(16,2), --_prima_bruta,
		  decimal(16,2), --_diezporc,
		  char(10),		 --_cod_contratante  
		  integer,
		  char(50);

define _no_poliza	    char(10);	 
define _cod_contratante char(10);	 
define _prima_bruta	    dec(16,2);	 
define _user_added   	char(8);
define _cod_no_renov   	char(3);
define _no_documento	char(20);
define _renovar   		smallint;
define _no_renovar		smallint;
define _fecha_selec		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _saldo			dec(16,2);
define _cant_reclamos	smallint;
define _no_factura		char(10);
define _incurrido		dec(16,2);
define _pagos   		dec(16,2);
define _porc_depreciacion  dec(5,2);
define _cod_agente  	char(5);
define _saldo_porc      integer;
define _n_cliente       varchar(100);
define _n_corredor      varchar(50);
define _diezporc      	dec(16,2);
define _fecha_hoy       date;
define _dias            integer;
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _n_subramo       char(50);
define _gerarquia       smallint;
define _tipo_ramo       char(1);

DEFINE _no_unidad		CHAR(5);
DEFINE _cod_tipoveh		CHAR(3);
DEFINE _uso_auto		CHAR(1);
DEFINE _no_motor		CHAR(30);
define _nuevo           smallint;
define _usuario   		char(8);
define _cod_compania    char(3);
define _cod_sucursal    char(3);
define _centro_costo    char(3);
define _filas           smallint;
define _retorno,_cnt         smallint;
define _error           integer;

let _fecha_hoy = current;
LET _tipo_ramo = null;
let _gerarquia = null;

SET ISOLATION TO DIRTY READ;

begin work;

begin
on exception set _error
    rollback work;
	return "Error " || _no_documento, null, null, null, null, 0, 0, '01-01-1900', '01-01-1900', '01-01-1900', 0, 0, null, 0, 0, 0, null, null, 0, 0 , null, _error, null;
end exception

	foreach
	  SELECT no_poliza,   
			 user_added,   
			 cod_no_renov,   
			 no_documento,   
			 renovar,   
			 no_renovar,   
			 fecha_selec,   
			 vigencia_inic,   
			 vigencia_final,   
			 saldo,   
			 cant_reclamos,   
			 no_factura,   
			 incurrido,   
			 pagos,   
			 porc_depreciacion,   
			 cod_agente  
		INTO _no_poliza,
			 _user_added,   
			 _cod_no_renov,   
			 _no_documento,   
			 _renovar,   
			 _no_renovar,   
			 _fecha_selec,   
			 _vigencia_inic,   
			 _vigencia_final,   
			 _saldo,   
			 _cant_reclamos,   
			 _no_factura,   
			 _incurrido,   
			 _pagos,   
			 _porc_depreciacion,
			 _cod_agente  
		FROM emirepo  
	   WHERE user_added IN ('MJARAMIL','YARIOS','MRGONZAL','JAQUELIN')
	     and estatus = 2
		 
		{select count(*)
          into _cnt
          from emideren
         where no_poliza = _no_poliza
           and renglon   = 66;		--ASEGURADO CON NOTAS RELEVANTES SD 13120 MARIELIS

		IF _cnt is null THEN
			let _cnt = 0;
		end IF
		if _cnt > 0 THEN
			continue foreach;
		end IF}
		
		SELECT cod_contratante,
			   prima_bruta,
			   cod_ramo,
			   cod_subramo,
			   cod_compania,
			   cod_sucursal
		  INTO _cod_contratante,
			   _prima_bruta,
			   _cod_ramo,
			   _cod_subramo,
			   _cod_compania,
			   _cod_sucursal
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
		IF _cod_ramo IN ('014','013') THEN
			CONTINUE FOREACH;
		END IF
		
		update emideren
			set activo    = 1
		 where no_poliza = _no_poliza;		
		 
		LET _usuario = sp_pro331(_no_poliza);

		update emirepo
		   set user_added = _usuario
		 where no_poliza  = _no_poliza;	

	    select centro_costo
	      into _centro_costo
	      from insagen
	     where codigo_agencia  = _cod_sucursal 
		   and codigo_compania = _cod_compania;
		 
		LET _usuario = sp_pro332(_centro_costo, 5);
		
		update emirepo
		   set estatus = 4,
			   user_added = _usuario
		 where no_poliza  = _no_poliza;
		
		let _filas = 0;
		
		select count(*) 
		  into _filas 
		  from emirepol 
		 where no_poliza = _no_poliza;
		 
		if _filas is null then
			let _filas = 0;
		end if
		 
		if _filas = 0 then
			let _retorno = sp_pro318(_no_poliza);
        end if		

	  select nombre
		into _n_subramo
		from prdsubra
	   where cod_ramo    = _cod_ramo
		 and cod_subramo = _cod_subramo;

	  select saldo_porc
		into _saldo_porc
		from emirepar;
			
	  if _saldo_porc is null then
		let _saldo_porc = 10;
	  end if

	  let _diezporc = 0;
	  let _diezporc = _prima_bruta * (_saldo_porc/100);

	  SELECT nombre
		INTO _n_cliente
		FROM cliclien
	   WHERE cod_cliente = _cod_contratante;

	  SELECT nombre
		INTO _n_corredor
		FROM agtagent
	   WHERE cod_agente = _cod_agente;

		let _dias = _fecha_hoy - _fecha_selec;
		if _cod_ramo in ('023','020','002') then	--preguntar '002',SD#5155 JEPËREZ	
		 {
		 TIPO VEHICULO	003 TAXIS
		 USO	COMERCIAL – C
		 CONDICION	NUEVO	USADO
		 % DEPRECIACION	20	15			 
		 }	
		foreach
			SELECT no_motor,
				   cod_tipoveh,
				   uso_auto
			  INTO _no_motor,
				   _cod_tipoveh,
				   _uso_auto
			  FROM emiauto
			 WHERE no_poliza = _no_poliza
		 
			select nuevo
			  into _nuevo
			  from emivehic
			 where no_motor = _no_motor;	 
			
			 if _cod_tipoveh = '003' then
				if _uso_auto = 'C' then
					if _nuevo = 1 then
						let _porc_depreciacion	= 20;	
					else
						let _porc_depreciacion	= 15;							
					end if	

				end if
			 end if 
			 
			 if _porc_depreciacion > 0 then 
				exit foreach;
			 end if
		 
		end foreach	 
	   
	  end if
	  --let _porc_depreciacion	= 20;	
	  
	   return _n_corredor,
			  _no_poliza,
			  _user_added,   
			  _cod_no_renov,   
			  _no_documento,   
			  _renovar,   
			  _no_renovar,   
			  _fecha_selec,   
			  _vigencia_inic,   
			  _vigencia_final,   
			  _saldo,   
			  _cant_reclamos,   
			  _no_factura,   
			  _incurrido,   
			  _pagos,   
			  _porc_depreciacion,
			  _cod_agente,
			  _n_cliente,
			  _prima_bruta,
			  _diezporc,
			  _cod_contratante,
			  _dias,
			  _n_subramo
			  with resume;
	end foreach
	end
    commit work;	  
END PROCEDURE

