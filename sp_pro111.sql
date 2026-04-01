-- Reporte de Verificacion de Polizas No Renovadas

-- Creado    : 28/02/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 28/02/2003 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro111;

create procedure sp_pro111(a_compania CHAR(3))
returning char(20),
          date,
		  date,
		  char(50),
		  date,
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  char(8),
		  char(1);

define _user_added		char(8);
define _fecha			date;
define _no_documento	char(20);
define _fecha_selec		date;
define _cod_cliente		char(10);
define _desc_cliente	char(50);
define _no_poliza		char(10);
define _desc_compania	char(50);
define _saldo			dec(16,2);
define _incurrido		dec(16,2);
define _vigencia_inic	date;
define _vigencia_final	date;
define _renovada		smallint;
define _estatus_poliza	smallint;
define _estatus			char(1);

define _cod_tipocan		char(3);
define _no_endoso		char(5);
define _user_added_end	char(8);
define _fecha_emision	date;
define _cod_no_renov	char(3);

define _no_pol_ult_vig	char(10);
define _cod_ramo		char(3);
define _fecha_limite	date;

let _fecha = today;
let _desc_compania = sp_sis01(a_compania); 
let _fecha_limite  = mdy(12,31,2001);

foreach
 select	no_poliza,
        user_added,
		no_documento,
		fecha_selec,
		saldo,
		incurrido,
		vigencia_inic,
		vigencia_final
   into	_no_poliza,
        _user_added,
		_no_documento,
		_fecha_selec,
		_saldo,
		_incurrido,
		_vigencia_inic,
		_vigencia_final
   from emirepol
  where (_fecha - vigencia_final) > 30
  order by user_added, vigencia_final desc

	select cod_contratante,
	       renovada,
		   estatus_poliza,
		   cod_ramo
	  into _cod_cliente,
	       _renovada,
		   _estatus_poliza,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza = 2 then

		let _estatus = "C";

	else

		let _estatus = "";

	end if

	select nombre
	  into _desc_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	return _no_documento,
		   _vigencia_inic,
		   _vigencia_final,	
		   _desc_cliente,
		   _fecha_selec,
		   _saldo,
		   _incurrido,
		   _desc_compania,
		   _user_added,
		   _estatus
		   with resume;

end foreach		   		

end procedure