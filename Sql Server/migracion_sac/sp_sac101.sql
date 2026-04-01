-- Procedure que Actualiza los Saldos de todo el Ano

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac101;

create procedure sp_sac101(a_ano_eval char(4)) 
returning integer, char(50);

define _tipo			char(2);
define _cuenta			char(25);
define _ccosto			char(3);
define _mes_ant			smallint;
define _cta_auxiliar	char(1);
define _cod_auxiliar	char(5);

define _saldop			dec(16,2);
define _saldop_acum		dec(16,2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _i				smallint;
define _cantidad		smallint;

define _cuenta_eva		char(25);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _tipo = "01";
--let _cuenta_eva = "111020101"; --"23101010101"

update cglsaldodet
   set sldet_saldop = sldet_debtop + sldet_cretop
 where sldet_ano    = a_ano_eval ;
--   and sldet_cuenta = _cuenta_eva;

update cglsaldoaux1
   set sld1_saldo   = sld1_debitos + sld1_creditos
 where sld1_ano     = a_ano_eval ;
--   and sld1_cuenta  = _cuenta_eva;
    
foreach
 select cta_cuenta,
        cta_auxiliar
   into _cuenta,
        _cta_auxiliar
   from cglcuentas
--  where cta_cuenta = _cuenta_eva

	foreach
	 select cen_codigo
	   into _ccosto
	   from sac:cglcentro
	
		for _i = 1 to 14 
			
			select sldet_saldop
			  into _saldop
			  from cglsaldodet
			 where sldet_tipo    = _tipo
			   and sldet_cuenta  = _cuenta
			   and sldet_ccosto  = _ccosto
			   and sldet_ano     = a_ano_eval
			   and sldet_periodo = _i;

			if _saldop is null then

				let _saldop = 0.00;
				
				select count(*)
				  into _cantidad
				  from cglsaldoctrl
				 where sld_tipo    = _tipo
				   and sld_cuenta  = _cuenta
				   and sld_ccosto  = _ccosto
				   and sld_ano     = a_ano_eval;

				if _cantidad = 0 then

					insert into cglsaldoctrl
					values (_tipo, _cuenta, _ccosto, a_ano_eval, 0);

				end if

				insert into cglsaldodet
				values (_tipo, _cuenta, _ccosto, a_ano_eval, _i, 0.00, 0.00, 0.00);

			end if

			if _i = 1 then
			
				 select sld_incioano
				   into _saldop_acum
				   from cglsaldoctrl
				  where sld_tipo   = _tipo
		            and sld_cuenta = _cuenta
				    and sld_ccosto = _ccosto
		            and sld_ano	   = a_ano_eval;

			else

				let _mes_ant = _i - 1;

				 select sldet_saldop
				   into _saldop_acum
				   from cglsaldodet
				  where sldet_tipo 	  =	_tipo
		            and sldet_cuenta  =	_cuenta
				    and sldet_ccosto  =	_ccosto
		            and sldet_ano	  =	a_ano_eval
			        and sldet_periodo =	_mes_ant;

			end if
			 
			let _saldop_acum = _saldop_acum + _saldop;

		   update cglsaldodet
		      set sldet_saldop  = _saldop_acum
		    where sldet_tipo    = _tipo
		      and sldet_cuenta  = _cuenta
		      and sldet_ccosto  = _ccosto         
		      and sldet_ano     = a_ano_eval
		      and sldet_periodo = _i;

		end for

	end foreach

	if _cta_auxiliar = "S" then

		foreach
		 select aux_tercero
		   into _cod_auxiliar
		   from cglauxiliar
		  where aux_cuenta = _cuenta

			for _i = 1 to 14 
				
				select sld1_saldo
				  into _saldop
				  from cglsaldoaux1
				 where sld1_tipo    = _tipo
				   and sld1_cuenta  = _cuenta
				   and sld1_tercero = _cod_auxiliar
				   and sld1_ano     = a_ano_eval
				   and sld1_periodo = _i;

				if _saldop is null then

					let _saldop = 0.00;
					
					select count(*)
					  into _cantidad
					  from cglsaldoaux
					 where sld_tipo    = _tipo
					   and sld_cuenta  = _cuenta
					   and sld_tercero = _cod_auxiliar
					   and sld_ano     = a_ano_eval;

					if _cantidad = 0 then

						insert into cglsaldoaux
						values (_tipo, _cuenta, _cod_auxiliar, a_ano_eval, 0);

					end if

					insert into cglsaldoaux1
					values (_tipo, _cuenta, _cod_auxiliar, a_ano_eval, _i, 0.00, 0.00, 0.00);

				end if

				if _i = 1 then
				
					 select sld_incioano
					   into _saldop_acum
					   from cglsaldoaux
					  where sld_tipo    = _tipo
			            and sld_cuenta  = _cuenta
					    and sld_tercero = _cod_auxiliar
			            and sld_ano	    = a_ano_eval;

				else

					let _mes_ant = _i - 1;

					 select sld1_saldo
					   into _saldop_acum
					   from cglsaldoaux1
					  where sld1_tipo 	 = _tipo
			            and sld1_cuenta  = _cuenta
					    and sld1_tercero = _cod_auxiliar
			            and sld1_ano	 = a_ano_eval
				        and sld1_periodo = _mes_ant;

				end if
				 
				let _saldop_acum = _saldop_acum + _saldop;

			   update cglsaldoaux1
			      set sld1_saldo   = _saldop_acum
			    where sld1_tipo    = _tipo
			      and sld1_cuenta  = _cuenta
			      and sld1_tercero = _cod_auxiliar         
			      and sld1_ano     = a_ano_eval
			      and sld1_periodo = _i;

			end for

		end foreach

	end if

end foreach

end 

return 0, "Actualizacion Exitosa"; 

end procedure