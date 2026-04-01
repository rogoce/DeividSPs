-- Reporte de Gestiones para el Investigador

-- Creado    : 12/06/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 12/06/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cas046;	  

create procedure sp_cas046(a_compania char(3))
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
		  char(20);

define _cod_cobrador		char(3);
define _cod_gestion			char(3);
define _cod_cliente			char(10);
define _cod_cobrador_ant	char(3);
define _no_documento		char(20);

define _nombre_cobrador		char(50);
define _nombre_gestion		char(50);
define _nombre_gestor		char(50);
define _nombre_cliente		char(100);
define _ultima_gestion		char(100);
define _nombre_compania		char(50);

set isolation to dirty read;

let _nombre_compania = sp_sis01(a_compania);

foreach
 select	c.cod_cobrador,
 		c.cod_gestion,
        c.cod_cliente,
		c.cod_cobrador_ant,
		c.ultima_gestion
   into	_cod_cobrador,
 		_cod_gestion,
        _cod_cliente,
		_cod_cobrador_ant,
		_ultima_gestion
   from cascliente c, cobcobra a 
  where c.cod_cobrador  = a.cod_cobrador
    and a.tipo_cobrador in (7, 8)
	and c.cod_gestion   in ("002", "005", "018", "021", "030")
  order by cod_cobrador, cod_gestion, cod_cliente

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
		   _no_documento
		   with resume;

end foreach

end procedure
