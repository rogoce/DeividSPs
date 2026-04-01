-- Reporte de Cobros Legales
-- 
-- Creado    : 18/01/2013 - Autor: Amado Perez M. 
-- Modificado: 18/01/2013 - Autor: Amado Perez M.
-- Modificado: 20/08/2013 - Autor: Roman Gordón	-- Se Agrego el Campo de Recupero
-- SIS v.2.0 - d_cobr_sp_cob316_dw1 - DEIVID, S.A.

drop procedure sp_cob319;

create procedure "informix".sp_cob319()
 returning  varchar(100),	-- _asegurado,		1
            char(20),		-- _no_documento,	2
		  	varchar(50),	-- _abogado,		3
			dec(16,2),	    -- _prima			4
		  	dec(16,2),		-- _pagos,		5
			date,			-- _fecha_out,		6
			smallint;		-- _recupero		7
			
define _comentario			varchar(255);
define _asegurado			varchar(100);
define v_compania_nombre	varchar(50);
define _agente				varchar(50);  
define _abogado				varchar(50);
define _no_documento		char(20);
define _cod_contratante		char(10);
define _no_factura			char(10);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _cod_abogado			char(3);
define _prima_bruta_p		dec(16,2);
define _gasto_legal			dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _impuesto			dec(16,2);
define _prima				dec(16,2);
define _pagos				dec(16,2);
define _saldo				dec(16,2);
define _recupero			smallint;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_out			date;
define _fecha_in			date;
define _fecha				date;

set isolation to dirty read;

foreach 
	select no_documento,
		   fecha,
		   no_factura,
		   no_poliza,
		   prima,
		   pagos,
		   saldo,
		   cod_abogado,
		   fecha_in,
		   fecha_out,
		   gasto_legal,
		   comentario,
		   recupero
	  into _no_documento,
		   _fecha,
		   _no_factura,
		   _no_poliza,
		   _prima,
		   _pagos,
		   _saldo,
		   _cod_abogado,
		   _fecha_in,
		   _fecha_out,
		   _gasto_legal,
		   _comentario,
		   _recupero
	  from coboutleg
	 order by cod_abogado,recupero,no_documento

	select cod_contratante,
		   vigencia_inic,
		   vigencia_final
	  into _cod_contratante,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
       
	select prima_neta,
		   impuesto,
		   prima_bruta
	  into _prima_neta,
		   _impuesto,
		   _prima_bruta
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = "00000";

	foreach
		select prima_bruta
		  into _prima_bruta_p
		  from endedmae
		 where no_poliza = _no_poliza
		   and cod_endomov = "002"
		   and cod_tipocalc = "001"
		exit foreach;
	end foreach

	select nombre
	  into _asegurado
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre 
	  into _agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre_abogado
	  into _abogado
	  from recaboga
	 where cod_abogado = _cod_abogado;

	return	trim(_asegurado),
			_no_documento,
			trim(_abogado), 
			_prima,
			_pagos,
			_fecha_out,
			_recupero		   
		   with resume;
end foreach
end procedure;