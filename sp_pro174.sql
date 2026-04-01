-- Indice de Permanencia

-- Creado:	08/09/2006	Autor: Demetrio Hurtado Almanza


drop procedure sp_pro174;

create procedure sp_pro174()
returning integer,
          char(50);

define _no_documento	char(20);
define _nombre_agente	char(50);
define _no_poliza		char(10);
define _estatus_poliza	char(1);
define _ano_aniv		char(4);
define _mes_aniv		smallint;
define _periodo_aniv	char(7);
define _periodo_saldo	char(7);

define _cant_renovada	integer;
define _cant_vigentes	integer;
define _cant_bono		integer;

define _por_vencer		dec(16,2);      
define _exigible		dec(16,2);        
define _corriente		dec(16,2);        
define _monto_30		dec(16,2);         
define _monto_60		dec(16,2);         
define _monto_90		dec(16,2);
define _saldo			dec(16,2);

{
create table emicartaind(
no_documento	char(20),
periodo			char(7),
cant_renovada	integer,
cant_vigentes	integer,
cant_bono		integer
);

alter table emicartaind lock mode (row);
}

delete from emicartaind;

let _cant_renovada = 1;
let _periodo_saldo = sp_sis39(today);

foreach
 select no_documento,
        nombre_agente,
		year(fecha_aniv),
		month(fecha_aniv)
   into _no_documento,
        _nombre_agente,
		_ano_aniv,
		_mes_aniv
   from emicartasal

	if _mes_aniv < 10 then
		let _periodo_aniv = _ano_aniv || "-0" || _mes_aniv;
	else
		let _periodo_aniv = _ano_aniv || "-" || _mes_aniv;
	end if

	let _no_poliza	= sp_sis21(_no_documento);

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza = 1 then

		let _cant_vigentes = 1;

		CALL sp_cob33(
			 "001",
			 "001",	
			 _no_documento,
			 _periodo_saldo,
			 today
			 ) RETURNING _por_vencer,      
						 _exigible,         
						 _corriente,        
						 _monto_30,         
						 _monto_60,         
						 _monto_90,
						 _saldo;         

--		let _saldo = sp_cob175(_no_documento, _periodo_saldo);

		if _monto_90 = 0.00 then
			let _cant_bono = 1;
		else
			let _cant_bono = 0;
		end if

	else

		let _cant_vigentes = 0;
		let _cant_bono     = 0;

	end if
		

	insert into emicartaind
	values (_no_documento, _periodo_aniv, _cant_renovada, _cant_vigentes, _cant_bono);   

end foreach

return 0, "Actualizacion Exitosa";

end procedure