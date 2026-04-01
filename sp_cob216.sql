-- Consulta registros seleccionados para creación de endoso de pronto pago
-- Creado    : 04/09/2009 - Autor: Roberto Silvera
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob216;

create procedure "informix".sp_cob216()
returning char(10),char(20),char(100),dec(16,2),char(8);

define	v_nom_cont			char(100);
define	v_no_doc			char(20);
define	v_cod_contratante	char(10);
define	v_cod_pagador		char(10);
define	v_no_poliza			char(10);
define	v_user_added		char(8);
define	v_monto_desc		dec(16,2);
define	v_seleccionado		smallint;

begin

set isolation to dirty read;

foreach
	select no_poliza,
		   no_documento,
		   cod_pagador,
		   cod_contratante,
		   monto_descuento,
		   seleccionado,
		   user_added
	  into v_no_poliza,
		   v_no_doc,
		   v_cod_pagador,
		   v_cod_contratante,
		   v_monto_desc,
		   v_seleccionado,
		   v_user_added
	  from cobpronpa
	 where seleccionado = 0

	select nombre
	  into v_nom_cont
	  from cliclien
	 where cod_cliente =  v_cod_contratante;

	return v_no_poliza,
		   v_no_doc,
		   v_nom_cont,
		   v_monto_desc,
		   v_user_added with resume;
end foreach
end
end procedure;