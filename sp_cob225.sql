
--drop procedure sp_cob225;

create procedure sp_cob225()
returning smallint,
          char(50);

define a_no_remesa	char(10);
define _tipo_remesa	char(1);
define _no_recibo	char(10);

let a_no_remesa = "357870";

SELECT tipo_remesa
  INTO _tipo_remesa
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

-- Actualizacion del Numero de Comprobante Automatico
if _tipo_remesa in ('C', 'F', 'T') then

	let _no_recibo = sp_sis13("001", 'COB', '02', 'cob_no_comp');

	update cobredet
	   set no_recibo = "CD" || trim(_no_recibo)
	 where no_remesa = a_no_remesa;

end if

return 0, "Actualizacion Exitosa";

end procedure
