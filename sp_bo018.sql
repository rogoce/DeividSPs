-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo018;

create procedure "informix".sp_bo018()
returning integer,
          char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _ano			char(4);
define _periodo		smallint;
define _enlace 		char(10);
define _ccosto		char(3);
define _cia_comp	char(3);
define _monto		dec(16,2);
define _tipo		char(1);
define _res_ano_ant	char(2);
define _ano_ant		char(4);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select valor_parametro
  into _res_ano_ant
  from inspaag
 where codigo_compania = "001"
   and codigo_agencia  = "001"
   and aplicacion      = "SAC"
   and version         = "02"
   and codigo_parametro = "sac_ano_reserva";

-- Variacion de reserva de siniestros en tramite (A Diciembre)

delete from ef_sumas;

insert into ef_sumas
select ano + 1, periodo, enlace, ccosto, sum(sinvarressin + sinporrecrea), 0.00, cia_comp
  from ef_estfin
 where tipo_calculo = "A"
   and periodo      = 13
 group by ano, periodo, enlace, ccosto, cia_comp;

foreach
 select ano,
        enlace,
		ccosto,
        monto,
		cia_comp
   into _ano,
        _enlace,
		_ccosto,
        _monto,
		_cia_comp
   from	ef_sumas

	update ef_estfin
	   set sinvarressin2 = _monto * -1
     where ano           = _ano
       and enlace        = _enlace
       and ccosto        = _ccosto
       and tipo_calculo  = "A"
	   and cia_comp	     = _cia_comp;

end foreach

-- Movimiento solo para cuando no se ha cerrado el Ano fiscal anterior

if _res_ano_ant = "NO" then

	delete from ef_sumas;

	let _ano_ant = year(today) - 1;

	insert into ef_sumas
	select ano + 1, periodo, enlace, ccosto, sum(sinvarressin), 0.00, cia_comp
	  from ef_estfin
	 where tipo_calculo = "A"
	   and periodo      = 13
	   and ano          = _ano_ant
	 group by ano, periodo, enlace, ccosto, cia_comp;

	foreach
	 select ano,
	        enlace,
	     	ccosto,
	        monto,
		    cia_comp
	   into _ano,
	        _enlace,
		    _ccosto,
	        _monto,
		    _cia_comp 
	   from	ef_sumas

		update ef_estfin
		   set sinvarressin  = sinvarressin + _monto
		 where ano           = _ano
		   and enlace        = _enlace
		   and ccosto        = _ccosto
		   and tipo_calculo  = "A"
		   and cia_comp      = _cia_comp;

	end foreach

	delete from ef_sumas;

	insert into ef_sumas
	select ano + 1, periodo, enlace, ccosto, sum(sinporrecrea), 0.00, cia_comp
	  from ef_estfin
	 where tipo_calculo = "A"
	   and periodo      = 13
	   and ano          = _ano_ant
	 group by ano, periodo, enlace, ccosto, cia_comp;

	foreach
	 select ano,
	        enlace,
		    ccosto,
	        monto,
		    _cia_comp
	   into _ano,
	        _enlace,
		    _ccosto,
	        _monto,
		    _cia_comp
	   from	ef_sumas

		update ef_estfin
		   set sinporrecrea  = sinporrecrea + _monto
		 where ano           = _ano
		   and enlace        = _enlace
		   and ccosto        = _ccosto
		   and tipo_calculo  = "A"
		   and cia_comp      = _cia_comp;

	end foreach

end if

update ef_estfin
   set sinvarressin3 = (sinvarressin + sinporrecrea + sinvarressin2) * -1;

update ef_estfin
   set pre_sinvarressin3 = (pre_sinvarressin + pre_sinporrecrea + pre_sinvarressin2);

end

return 0, "Actualizacion Exitosa";

end procedure