-- Reporte especial para seguros centralizados de las Comisiones por Corredor - Detallado

-- Creado    : 15/06/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_actualiza_cliDG;
CREATE PROCEDURE sp_actualiza_cliDG()
RETURNING char(30);


DEFINE _cod_cliente  CHAR(10);
DEFINE _cedula,_ced_nva       CHAR(30);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

FOREACH
	select cod_cliente,
	       cedula
	  into _cod_cliente,
           _cedula	  
      from cliclien
     where cedula[1,1] = '-'
       and ced_inicial in('N','E','PE')
	   --and cod_cliente = '22455'
	   
	let _ced_nva = _cedula[2,30];
	  
    update cliclien
	   set cedula = _ced_nva
	 where cod_cliente = _cod_cliente;
	
	return _ced_nva with resume;
END FOREACH
END PROCEDURE;