-- Reporte de Gestiones para el Investigador
-- Creado    : 12/06/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 12/06/2003 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cas029;
create procedure sp_cas029(a_compania char(3),a_cod_cobrador char(3))
returning char(10),
          char(100),
		  char(100),
		  char(3),
		  char(50),
		  char(3),
		  char(50),
		  char(3),
		  char(50),
		  char(50),
		  char(20),
		  char(3),
		  char(3),
		  date;

define _nombre_cliente		varchar(100);
define _ultima_gestion		varchar(100);
define _nombre_cobrador		varchar(50);
define _nombre_compania		varchar(50);
define _nombre_gestion		varchar(50);
define _nombre_gestor		varchar(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_cobrador_ant	char(3);
define _cod_cobrador		char(3);
define _cod_gestion			char(3);
define _fecha_ult_pro		date;

set isolation to dirty read;

let _nombre_compania = sp_sis01(a_compania);

foreach
	select cod_cobrador,
		   cod_gestion,
		   cod_cliente,
		   cod_cobrador_ant,
		   ultima_gestion,
		   fecha_ult_pro
	  into _cod_cobrador,
		   _cod_gestion,
		   _cod_cliente,
		   _cod_cobrador_ant,
		   _ultima_gestion,
		   _fecha_ult_pro
	  from cascliente 
	 where cod_cobrador  = a_cod_cobrador
	 order by cod_cobrador,cod_gestion,cod_cliente

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select nombre
	  into _nombre_gestor
	  from cobcobra
	 where cod_cobrador = _cod_cobrador_ant;

	select nombre
	  into _nombre_gestion
	  from cobcages
	 where cod_gestion = _cod_gestion;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	foreach
		select no_documento
		  into _no_documento
		  from caspoliza
		 where cod_cliente = _cod_cliente
		exit foreach;
	end foreach

	return _cod_cliente,
		   _nombre_cliente,
		   _ultima_gestion,
		   _cod_cobrador_ant,
		   _nombre_gestor,
		   _cod_gestion,
		   _nombre_gestion,
		   _cod_cobrador,
		   _nombre_cobrador,
		   _nombre_compania,
		   _no_documento,
		   a_compania,
		   a_cod_cobrador,
		   _fecha_ult_pro
		   with resume;
end foreach
end procedure;