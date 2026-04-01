-- Procedimiento que Crea los Registros para los Auditores (Cobros)
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud43;

create procedure "informix".sp_aud43() returning char(10), char(20), varchar(100), date, date, varchar(50), varchar(50), char(8), char(15), varchar(50), dec(16,2);   

define _no_tramite		char(10);
define _numrecla		char(20);
define _cod_asegurado	char(10);
define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _cod_evento   	char(3);
define _cod_ajustador	char(3);
define _user_added  	char(8);
define _estatus_reclamo char(1);
define _no_poliza       char(10);
define _no_reclamo      char(10);
define _asegurado       varchar(100);
define _evento          varchar(50);
define _cod_ramo        char(3);
define _ramo            varchar(50);
define _incurrido_bruto dec(16,2);
define _ajustador       varchar(50);
define _estatus     	char(15);

define v_filtros        char(255);

set isolation to dirty read;

LET v_filtros = sp_rec01('001','001','2013-12','2013-12','*','*','002,020;','*','*','*','*','*'); 

foreach
	select no_tramite, numrecla, cod_asegurado, fecha_siniestro, fecha_reclamo, cod_evento, ajust_interno, user_added, estatus_reclamo, no_poliza, no_reclamo
	  into _no_tramite, _numrecla, _cod_asegurado, _fecha_siniestro, _fecha_reclamo, _cod_evento, _cod_ajustador, _user_added, _estatus_reclamo, _no_poliza, _no_reclamo
	  from recrcmae
	 where fecha_reclamo >= '01/12/2013'

    select nombre into _asegurado
	  from cliclien 
	 where cod_cliente = _cod_asegurado;

    select nombre into _evento
	  from recevent
	 where cod_evento = _cod_evento;

    select nombre into _ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select cod_ramo into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_ramo not in ('002','020') then
		continue foreach;
	end if

	select nombre into _ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

    if _estatus_reclamo = 'A' then
		let _estatus = "A - Abierto";
	elif _estatus_reclamo = 'C' then
		let _estatus = "C - Cerrado";
	elif _estatus_reclamo = 'D' then
		let _estatus = "D - Declinado";
	elif _estatus_reclamo = 'N' then
		let _estatus = "N - No Aplica";
    end if

   select incurrido_bruto into _incurrido_bruto
     from tmp_sinis
    where no_reclamo = _no_reclamo;

   return _no_tramite, _numrecla, _asegurado, _fecha_siniestro, _fecha_reclamo, _evento, _ajustador, _user_added, _estatus, _ramo, _incurrido_bruto with resume; 

end foreach

DROP TABLE tmp_sinis;

--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure