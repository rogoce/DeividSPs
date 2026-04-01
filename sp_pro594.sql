--Procedure que busca si la factura_lider ya fue procesada en otra carga -- Carga de pólizas de Coaseguro Minoritario
-- 13/01/2023 - Autor: Amado Perez.

drop procedure sp_pro594;
create procedure "informix".sp_pro594(a_cod_coasegur char(3), a_num_carga integer, a_factura_lider char(20), a_tipo_factura char(3))
returning	smallint        as Cantidad,
            integer         as Num_Carga,
            integer			as Renglon,
			char(20)		as Poliza,
			varchar(30)		as Poliza_Coaseg,
			char(10)        as Factura;

define _no_poliza_coaseg	varchar(30);
define _no_documento		char(20);
define _no_factura			char(10);
define _tipo_factura		char(3);
define _procesado			smallint;
define _renglon				smallint;
define _factura_lider       char(20);
define _orden               smallint;
define _num_carga           integer;
define _cnt                 smallint;

set isolation to dirty read;

let _cnt = 0;

select count(*)
  into _cnt
  from emicacoami
 where cod_coasegur = a_cod_coasegur
   and num_carga <> a_num_carga
   and factura_lider = a_factura_lider
   and tipo_factura = a_tipo_factura
   and procesado = 1;
   
if _cnt is null then
	let _cnt = 0;
end if

if _cnt > 0 then
	foreach
		select num_carga,
		       no_poliza_coaseg,
			   no_documento,
			   renglon,
			   no_factura
		  into _num_carga,
		       _no_poliza_coaseg,
			   _no_documento,
			   _renglon,
			   _no_factura
		  from emicacoami
		 where cod_coasegur = a_cod_coasegur
		   and num_carga <> a_num_carga
		   and factura_lider = a_factura_lider
		   and tipo_factura = a_tipo_factura
		   and procesado = 1
		 order by num_carga

		return	_cnt,
				_num_carga,
		        _renglon,
				_no_documento,			
				_no_poliza_coaseg,
				_no_factura;						
	end foreach
else
		return	0,
		        0,
				0,
				null,			
				null,
				null;						
end if	

end procedure;