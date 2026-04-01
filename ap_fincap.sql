-- 
-- Genera Información para la poliza 1619-00013-01 
-- Creado    : 07/04/2022 - Autor: Amado Perez

DROP PROCEDURE ap_fincap;
CREATE PROCEDURE ap_fincap() 
RETURNING char(10) as no_poliza, 
		  char(20) as no_documento,
		  char(3) as cod_perpago_ori,
          date as fecha_primer_pago_ori,
          date as vigencia_inicial,
		  date as fecha_primer_pago_new,
		  smallint as no_pagos;

	DEFINE _no_poliza 			char(10);
	DEFINE _no_documento        char(20);
 	DEFINE _vigencia_inic       date;
	DEFINE _fecha_primer_pago   date;
	DEFINE _cod_perpago          char(3);
	DEFINE _fecha_primer_pago_orig date;
	DEFINE _no_pagos            smallint;
         

SET ISOLATION TO DIRTY READ;
 -- set debug file to "sp_eco03.trc";	
 -- trace on;

FOREACH
	SELECT no_poliza,
	       no_documento,
	       vigencia_inic,
		   cod_perpago,
		   fecha_primer_pago,
		   no_pagos
	  INTO _no_poliza,
	       _no_documento,
	       _vigencia_inic,
		   _cod_perpago,
		   _fecha_primer_pago_orig,
		   _no_pagos
	  FROM emipomae
     where cod_grupo = '00087'
       and estatus_poliza = 1
       and cod_perpago <> '005'	 
	   and actualizado = 1
	   and no_documento not in ('0215-01479-01','0213-02170-01','0218-01522-01','0217-02058-01','0214-03171-01','1698-00105-01','0217-00108-01','0214-00497-01','0321-00059-01','0621-00127-01')
	   
	let _fecha_primer_pago = _vigencia_inic + 120 units day;   
	{
	update emipomae
	   set fecha_primer_pago = _fecha_primer_pago,
	       cod_perpago = '005'
	 where no_poliza = _no_poliza;

    update endedmae	 
	   set fecha_primer_pago = _fecha_primer_pago,
	       cod_perpago = '005'
	 where no_poliza = _no_poliza
	   and no_endoso = '00000';
	 }  
	return _no_poliza, _no_documento, _cod_perpago, _fecha_primer_pago_orig, _vigencia_inic, _fecha_primer_pago, _no_pagos with resume;   
END FOREACH



--return 0, "actualizacion exitosa";
END PROCEDURE	  