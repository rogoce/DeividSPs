--- Renovacion Automatica.
--- Creado 02/03/2009 por Armando Moreno

drop procedure sp_cob248b;

create procedure "informix".sp_cob248b(a_no_remesa char(10))
returning integer,
		  char(50);

define v_documento  	char(20);
define v_factura    	char(10);
define v_renovar    	smallint;
define v_cod_renovar 	smallint;
define v_cod_no_renovar char(3);
define _cod_ramo        char(3);
define _no_poliza       char(10);
define v_vigencia_inic  date;
define _vig_inic_ult    date;
define v_vigencia_fin   date;
define v_tipo       	char(3);
define v_saldo      	decimal(16,2);
define v_cant       	smallint;
define v_cantidad   	smallint;
define v_incurrido  	decimal(16,2);
define v_pagos      	decimal(16,2);
define v_tot_pagos  	decimal(16,2);
define _suma_asegurada	decimal(16,2);
define _perd_total  	smallint;
define _todas_perdida  	smallint;
define _cod_compania   	char(3);
define _codigo_agencia	char(3);
define _cod_sucursal   	char(3);
define _centro_costo   	char(3);
define _usuario      	char(8);
define _cnt			  	smallint;
define _cantidad	  	smallint;
define _cod_agente      char(5);
define _porc_partic  	decimal(5,2);
define _vig_final		date;
define _cod_tipoprod    char(3);
define _cod_grupo       char(5);
define _salir           smallint;
define _cod_subramo     char(3);
define _fecha           date;
define _cod_manzana     char(15);
define _cod_asegurado   char(10);
define _fecha_aniversario date;
define _edad            integer;
define _no_unidad       char(5);
define _activo          smallint;
define _cod_acreedor    char(5);
define _ano_auto        smallint;
define _cod_cobertura   char(5);
define _estatus         smallint;
define _prima_bruta     decimal(16,2);
define _diezporc	    decimal(16,2);
define _saldo           decimal(16,2);
define _renglon         smallint;
define _reg             integer;
define _usu_cob         char(8);
define _porcentaje      integer;
define _declarativa     smallint;
define _gerarquia       smallint;
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define li_cnt           smallint;
define ls_usuario       char(8);
define _serie           integer;
define _no_p            char(10);
define _vig_ini         date;
define _vig_fin         date;
define _usuario_cobros  char(8);
define _cod_contr       char(10);
define _bander          smallint;
define _valor           integer;
define _no_pagos        smallint;
define a_periodo        char(7);
define _fecha_aa        date;
define v_por_vencer		decimal(16,2);
define v_exigible		decimal(16,2);
define v_corriente		decimal(16,2);
define v_monto_30		decimal(16,2);
define v_monto_60		decimal(16,2);
define v_monto_90		decimal(16,2);
define _flag_moro       smallint;
define _error_isam		integer;
define _error			integer;
define _error_desc		char(50);

--SET D_saldo;   EBUG FILE TO "sp_cob248b.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;
begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fecha           = current;
let v_pagos          = 0;
let v_incurrido      = 0;
let v_cantidad       = 0;
let v_saldo          = 0;
let v_renovar        = 0;
let v_cod_renovar    = 0;
let _salir 			 = 0;
let v_factura        = NULL;
let v_cod_no_renovar = NULL;
let _prima_bruta     = 0;
let _ano_auto        = 0;
let _porcentaje      = 10;
let li_cnt           = 0;
let _bander          = 0;
let _valor           = 0;

select usuario_cobros
  into _usuario_cobros
  from emirepar;

select par_periodo_act
  into a_periodo
  from parparam;

let _fecha_aa = sp_sis36(a_periodo);

foreach
	select no_poliza
	  into _no_poliza
	  from cobredet
	 where no_remesa = a_no_remesa
       and tipo_mov  = 'P'	 
	foreach

		select no_documento,
			   estatus
		  into v_documento,
			   _estatus
		  from emirepo
		 where (user_added = _usuario_cobros
			or user_cobros = _usuario_cobros)
		   and estatus not in(5,9)
		   and no_poliza  = _no_poliza

		select count(*)
		  into li_cnt
		  from emideren
		 where no_poliza = _no_poliza;

		let _flag_moro   = 0;

		select cod_formapag,prima_bruta,cod_ramo,cod_subramo,cod_contratante,no_pagos
		  into _cod_formapag,_prima_bruta,_cod_ramo,_cod_subramo,_cod_contr,_no_pagos
		  from emipomae
		 where no_poliza = _no_poliza;

		SELECT tipo_forma
		  INTO _tipo_forma
		  FROM cobforpa
		 WHERE cod_formapag = _cod_formapag;

		let _saldo = 0;
		let _saldo = sp_cob115b('001','001',v_documento,'');
	
		if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach

			select usuario_cobros,
				   saldo_elect
			  into _usu_cob,
				   _porcentaje
			  from emirepar;

		else
			
			select usuario_cobros,
				   saldo_porc
			  into _usu_cob,
				   _porcentaje
			  from emirepar;

		end if
		if _cod_ramo in("002",'023') then
			foreach
				select cod_agente
				  into _cod_agente
				  from emipoagt
				 where no_poliza = _no_poliza

				if _cod_agente = "00161" then  --General Representatives es 25%	Armando 17//05/2011 Aut. por Leticia Escobar.
					let _porcentaje = 25;
					exit foreach;
				end if

				if _cod_agente = "00218" then  --Kam Panama
					exit foreach;
				end if

			end foreach

			let _bander = 0;
			select count(*)
			  into _bander
			  from emipouni
			 where no_poliza     = _no_poliza
			   and cod_asegurado = "84250";  --Pacific Leasing

			if _bander > 0 or _cod_contr = "84250" then
				if _cod_agente = "00218" then  --Es Pacific Leasing y corredor Kam Panama, porc debe ser 20% sol. por Nixia Morales 29/09/2011, Armando.
					let _porcentaje = 20;
				end if
			end if
		end if

		let _diezporc = 0;
		let _diezporc = _prima_bruta * (_porcentaje / 100);
		let _usu_cob  = trim(_usu_cob);

		let _saldo    = _saldo;
		let _diezporc = _diezporc;

		if _saldo is null then
			let _saldo = 0;
		end if

		if _no_pagos = 12 then

			call sp_cob33('001','001', v_documento, a_periodo, _fecha_aa)
				 returning v_por_vencer,    
						   v_exigible,      
						   v_corriente,    
						   v_monto_30,      
						   v_monto_60,      
						   v_monto_90,
						   _saldo;   
			if v_monto_90 = 0 then --No tiene moro a mas de 90 dias
				let _flag_moro = 1;
			end if
		end if

		if _saldo > _diezporc AND _flag_moro = 0 then
			continue foreach;
		else
			if li_cnt > 1 then
				update emideren
				   set activo     = 1
				 where no_poliza  = _no_poliza
				   and renglon    = 11;

				let _usuario = sp_pro331(_no_poliza);

				update emirepo
				   set user_added  = _usuario,
					   user_cobros = null,
					   saldo       = _saldo
				 where no_poliza   = _no_poliza;

			elif li_cnt = 1	then

				select renglon
				  into _cnt
				  from emideren
				 where no_poliza = _no_poliza;

			   if _cnt = 11 then

				   if v_documento[1,2] not in ("13","14","17","06") then
					  if _cod_ramo = '009' and _cod_subramo = "001" then --Transporte subramo terrestre anual

							update emideren
							   set activo    = 1
							 where no_poliza = _no_poliza
							   and renglon   = 11;

							let _usuario = sp_pro331(_no_poliza);

							update emirepo
							   set user_added  = _usuario,
								   user_cobros = null,
								   saldo       = _saldo
							 where no_poliza   = _no_poliza;

					  else

						{if _cod_ramo = '020' then --polizas SODA deben ir al pool manual.
							let _valor = sp_pro318(_no_poliza);  --Inserta en el poool manual
							delete from emideren
							 where no_poliza = _no_poliza;
							delete from emirepo
							 where no_poliza = _no_poliza;
						else}

							update emirepo
							   set estatus     = 1,
								   user_added  = "AUTOMATI",
								   user_cobros = null,
								   saldo       = _saldo
							 where no_poliza   = _no_poliza;

							delete from emideren
							 where no_poliza = _no_poliza;
						--end if
					  end if
				   else
						update emirepo
						   set saldo     = _saldo
						 where no_poliza = _no_poliza;

				   end if
			   end if

			end if

		end if

	end foreach
end foreach

return 0,'Actualización Exitosa';
end
end procedure;
