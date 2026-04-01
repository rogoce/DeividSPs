-- Procedimiento para retorna los valores para la carta al cliente de salud por Morosidad a mas de 60 dias
-- por la no facturacion de las polizas de salud.
--
-- Creado    : 21/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob116b;

create procedure "informix".sp_cob116b(a_mail_secuencia integer)
returning char(100),
          char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          char(100),
          char(50),
          char(50),
          char(100),
          char(10),
          char(50);

define _cod_pagador		char(10);
define _cod_supervisor	char(3);
define _cod_formapag	char(3);
define _cod_zona		char(3);
define _cod_agente		char(5);
define _nombre_pagador	char(100);
define _no_documento  	char(20);
define _saldo			dec(16,2);
define _saldo61			dec(16,2);
define _prima_mensual	dec(16,2);
define _asegurado		char(100);
define _nom_supervisor	char(50);
define _nom_zona		char(50);
define _nom_agente		char(100);
define _cod_ramo        char(3);
define _n_ramo          char(50);

define _no_poliza		char(10);

set isolation to dirty read;

--set debug file to "sp_cob272.trc";
--trace on;

let _cod_agente = '';

select no_remesa
  into _no_poliza
  from parmailcomp
 where mail_secuencia = a_mail_secuencia;
   
select cod_pagador,
	   cod_formapag,
	   cod_ramo
  into _cod_pagador,
	   _cod_formapag,
	   _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select cod_cobrador
  into _cod_zona
  from cobforpa
 where cod_formapag = _cod_formapag;

foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza
	 order by porc_partic_agt desc
	exit foreach;	
end foreach

if _cod_zona is null or _cod_zona = '' then
	select cod_cobrador
	  into _cod_zona
	  from agtagent
	 where cod_agente = _cod_agente;		
end if

select nombre,
	   cod_supervisor
  into _nom_zona,
  	   _cod_supervisor
  from cobcobra
 where cod_cobrador = _cod_zona;

select nombre
  into _nom_supervisor
  from cobcobra
 where cod_cobrador = _cod_supervisor;

select nombre
  into _n_ramo
  from prdramo
 where cod_ramo = _cod_ramo;

select nombre
  into _nom_agente
  from agtagent
 where cod_agente = _cod_agente;

select nombre
  into _nombre_pagador
  from cliclien
 where cod_cliente = _cod_pagador;

select prima_bruta,
       monto_descuento,
	   no_documento
  into _prima_mensual,
       _saldo61,
	   _no_documento
  from cobpronde
 where no_poliza = _no_poliza;

return _nombre_pagador,
       _no_documento,
	   0,--_saldo,
	   _saldo61,
	   _prima_mensual,
       '',--_asegurado,
       _nom_supervisor,
       _nom_zona,
       _nom_agente,
       _cod_pagador,
       _n_ramo;
end procedure