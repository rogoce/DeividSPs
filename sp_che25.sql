-- Cheques no Pagados Remesas Visa y ACH del 14-06-2004

-- Creado    : 21/06/2004 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che25;

CREATE PROCEDURE sp_che25()
returning char(5),
          char(50),
		  char(10),
		  char(10),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _cod_agente	char(5);
define _monto		dec(16,2);
define _prima_neta	dec(16,2);
define _comision	dec(16,2);
define _nombre		char(50);
define _telefono1	char(10);
define _telefono2	char(10);
define _celular		char(10);

--set debug file to "sp_che25.trc";
--trace on;

foreach
 select c.cod_agente, 
	    sum(r.monto), 
	    sum(r.prima_neta), 
	    sum((r.prima_neta * (c.porc_comis_agt/100) * (c.porc_partic_agt/100)))
   into _cod_agente,
        _monto,
		_prima_neta,
		_comision
   from cobredet r, cobreagt c
  where r.no_remesa in ("55899", "55962")
    and r.tipo_mov in ("P", "N")
    and r.no_remesa = c.no_remesa
    and r.renglon   = c.renglon
  group by c.cod_agente
  order by c.cod_agente

	select nombre,
	       telefono1,
		   telefono2,
		   celular
	  into _nombre,
	       _telefono1,
		   _telefono2,
		   _celular
	  from agtagent
	 where cod_agente = _cod_agente;

	return _cod_agente,
	       _nombre,
		   _telefono1,
		   _telefono2,
		   _celular,
		   _monto,
		   _prima_neta,
		   _comision
		   with resume;

end foreach

end procedure
