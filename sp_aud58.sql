-- Procedimiento reclamo de siniestro de 2016 a la fecha
-- Creado     : 15/09/2004 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud58;
create procedure "informix".sp_aud58() 
returning char(20) as Poliza,
char(5) as Unidad,
char(10) as NoTramite, 
char(20) as num_reclamo, 
varchar(100) as Asegurado, 
date as fecha_siniestro, 
date as fecha_reclamo, 
varchar(50) as evento, 
varchar(50) as ajustador, 
char(8) as user_added, 
char(15) as estatus, 
varchar(50) as ramo,
dec(16,2) as suma_asegurada;  

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
define _no_unidad       char(5);
define _no_documento    CHAR(20);
DEFINE _cod_cliente      CHAR(10);
DEFINE _no_reclamo      CHAR(10);
define _suma_asegurada  dec(16,2);

define v_filtros        char(255);

set isolation to dirty read;
let _incurrido_bruto = 0;
LET v_filtros = ''; --sp_rec01('001','001','2013-12','2013-12','*','*','002,020;','*','*','*','*','*'); 

foreach
	select no_tramite, numrecla, cod_asegurado, fecha_siniestro, fecha_reclamo, cod_evento, ajust_interno, user_added, estatus_reclamo, no_poliza, no_reclamo, no_unidad, no_documento, suma_asegurada
	  into _no_tramite, _numrecla, _cod_asegurado, _fecha_siniestro, _fecha_reclamo, _cod_evento, _cod_ajustador, _user_added, _estatus_reclamo, _no_poliza, _no_reclamo, _no_unidad, _no_documento, _suma_asegurada
	  from recrcmae
	  WHERE fecha_siniestro >= '01/01/2016'  AND
            fecha_siniestro <= '30/03/2019'  AND
            numrecla[1,2] in ( '16' )  aND actualizado = 1

    select nombre into _asegurado
	  from cliclien 
	 where cod_cliente = _cod_asegurado;

    select nombre into _evento
	  from recevent
	 where cod_evento = _cod_evento;

    select nombre into _ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select cod_ramo,cod_contratante into _cod_ramo,_cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_ramo not in ('016') then
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

   {select incurrido_bruto into _incurrido_bruto
     from tmp_sinis
    where no_reclamo = _no_reclamo;}

   return _no_documento, _no_unidad, _no_reclamo, _numrecla, _asegurado, _fecha_siniestro, _fecha_reclamo, _evento, _ajustador, _user_added, _estatus, _ramo,_suma_asegurada with resume; 

end foreach

--DROP TABLE tmp_sinis;

--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure