--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245b('2024-09') 

drop procedure sp_cob432;

create procedure sp_cob432()
returning	char(20)		as no_documento,
			char(4)			as agno,
			dec(16,2)	    as prima_suscrita,
			dec(16,2)	    as prima_pagada;

define _no_documento			char(20);           
define _no_poliza 				char(10);  
define _agno                    char(4);
define _prima_suscrita          dec(16,2);
define _prima_pagada            dec(16,2);       
DEFINE _no_remesa    			CHAR(10);     
DEFINE _cod_coasegur 			CHAR(3);  
DEFINE _porcentaje   			DEC(16,4);



--set debug file to "sp_sis245.trc";
--trace on;
CREATE TEMP TABLE tmp_montos(
		no_poliza           CHAR(10)  NOT NULL,
		no_documento        CHAR(20)  NOT NULL,
		agno                 CHAR(4),
		prima_suscrita      DEC(16,2) DEFAULT 0 NOT NULL,
		prima_pagada		DEC(16,2) DEFAULT 0 NOT NULL
		) WITH NO LOG;

CREATE INDEX xie01_tmp_montos ON tmp_montos(no_poliza);

SELECT par_ase_lider
  INTO _cod_coasegur
  FROM parparam
 WHERE cod_compania = '001';



foreach
	select no_poliza, 
	       no_documento, 
		   periodo[1,4], 
		   prima_suscrita
      into _no_poliza,
           _no_documento,
           _agno,
           _prima_suscrita		   
	  from endedmae
	where actualizado = 1
	  and no_documento in ('1614-00078-01',
						   '1614-00079-01',
						   '1614-00080-01',
						   '1614-00081-01',
						   '1616-00005-01',
						   '1616-00006-01')
	  and periodo >= '2018-01'
	  and periodo <= '2024-05'

	INSERT INTO tmp_montos(
	no_poliza,    
    no_documento,
    agno,	
	prima_suscrita
	)
	VALUES(
	_no_poliza,
	_no_documento,
	_agno,
	_prima_suscrita
	);

end foreach	  
  
-- Primas Pagadas


FOREACH
 SELECT	no_poliza,
        doc_remesa,
		periodo[1,4],
        prima_neta
   INTO	_no_poliza,
        _no_documento,
		_agno,
        _prima_pagada
   FROM cobredet
  WHERE	actualizado  = 1
    AND tipo_mov IN ('P', 'N')
    AND periodo     >= '2018-01' 
    AND periodo     <= '2024-05'
	AND renglon     <> 0
	AND doc_remesa in ('1614-00078-01',
						   '1614-00079-01',
						   '1614-00080-01',
						   '1614-00081-01',
						   '1616-00005-01',
						   '1616-00006-01')

	SELECT porc_partic_coas
	  INTO _porcentaje
	  FROM emicoama
	 WHERE no_poliza    = _no_poliza
	   AND cod_coasegur = _cod_coasegur;
	   
	IF _porcentaje IS NULL THEN
		LET _porcentaje = 100;
	END IF	    

	LET _prima_pagada = _prima_pagada / 100 * _porcentaje;

	INSERT INTO tmp_montos(
	no_poliza, 
    no_documento,
    agno,	
	prima_pagada
	)
	VALUES(
	_no_poliza,
	_no_documento,
	_agno,
	_prima_pagada
	);

END FOREACH


foreach
	select no_documento,
	       agno,
		   sum(prima_suscrita),
		   sum(prima_pagada)
	  into _no_documento,
	       _agno,
	       _prima_suscrita,
		   _prima_pagada
	  from tmp_montos
	group by 1,2
	order by 1,2
	
	return _no_documento,
	       _agno,
	       _prima_suscrita,
		   _prima_pagada with resume;
end foreach
		
DROP TABLE tmp_montos;

end procedure;