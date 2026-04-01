-- Procedimiento cobertura producto de salud individual
-- Creado:	04/07/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro47i_obs('203069','00001')

drop procedure sp_pro47i_obs; 
create procedure sp_pro47i_obs(a_poliza CHAR(10), a_unidad char(5), a_pag smallint, a_page_count smallint)
returning varchar(200) as Observacion;

DEFINE v_observacion    CHAR(200);
       
--set debug file to "sp_pro47i_OBS.trc";
--trace on;
drop table if exists tmp_obs;
CREATE TEMP TABLE tmp_obs(
        secuencia        SMALLINT DEFAULT 1,
		observacion      CHAR(200) default ''
		) WITH NO LOG; 
		
set isolation to dirty read;


INSERT INTO tmp_obs(secuencia,observacion)
VALUES(1, 'NOTA DE ADVERTENCIA: la Compañía concederá al Contratante un período de gracia de treinta (30) días calendario para recibir el pago correspondiente. Si la Compañía no recibe el pago'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(2, 'de la prima antes de que el período de gracia expire, esta póliza y todos sus beneficios entraran en periodo de suspensión por el término de sesenta (60) días calendarios. La póliza se dará por'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(3, 'terminada quince (15) días calendario después de la fecha del envío del aviso de cancelación.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(4, '• POR FALTA DE PAGO DE LA PRIMA, POR PARTE DEL CONTRATANTE Y/O ASEGURADO, CUMPLIDOS LOS TÉRMINOS CONTENIDOS EN ESTA PÓLIZA Y LA LEY.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(5, 'DE UNIÓN CONSENSUAL DE HECHO.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(6, '• PARA EL CÓNYUGE DEL ASEGURADO, SI ES PERSONA CUBIERTA, AL DIVORCIARSE Y ESTO SE COMPRUEBE MEDIANTE SENTENCIA EN FIRME O UNA SEPARACIÓN FINAL, EN EL CASO'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(7, 'Serán causales de terminación de este contrato y por ende de su cobertura, las siguientes:'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(8, 'CUMPLE CON LA CONDICIÓN, EN EL MOMENTO QUE RESIDA FUERA DE LA REPÚBLICA DE PANAMÁ POR MÁS DE TRES (3) MESES.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(9, '• POR NO CUMPLIR CON LA CONDICIÓN DE RESIDIR PERMANENTEMENTE EN LA REPÚBLICA DE PANAMÁ: SE ENTIENDE QUE EL CONTRATANTE, ASEGURADO O PERSONA CUBIERTA NO'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(10, 'LA SOLICITUD EN LA COMPAÑÍA, LA FECHA QUE SEA POSTERIOR.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(11, '• LA ASEGURADORA TENDRÁ DERECHO A DAR POR TERMINADA ESTA PÓLIZA SI DESCUBRE O TIENE CONOCIMIENTO DE CUALQUIER DECLARACIÓN FALSA O INEXACTA DE HECHOS O'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(12, 'CIRCUNSTANCIAS CONOCIDAS POR EL ASEGURADO O SU CORREDOR QUE HUBIESEN PODIDO INFLUIR DE MODO DIRECTO EN LA DECISIÓN DE DAR COBERTURA BAJO ESTA PÓLIZA'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(13, 'O HABER OTORGADO COBERTURA EN CONDICIONES DISTINTAS DE HABER SIDO CONOCIDOS LOS HECHOS POR EL ASEGURADOR AL MOMENTO DE SUSCRIBIR LA PÓLIZA.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(14, 'Con fundamento en los artículos 154 y 155 del Capítulo II de la Ley 12 del 3 de abril del 2012, Usted debe cumplir con el pago total o primer pago fraccionado de la prima al momento de la emisión de'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(15, '• POR SOLICITUD DEL ASEGURADO: A SOLICITUD DEL ASEGURADO, EN LA FECHA EN QUE ÉL LO SOLICITE POR ESCRITO A LA COMPAÑÍA O A PARTIR DE LA FECHA EN QUE SEA RECIBIDA'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(16, 'PARÁGRAFO: NO HABRÁ LÍMITE DE EDAD EN LAS RENOVACIONES PARA LA COBERTURA DE LOS ASEGURADOS O PERSONA CUBIERTA O DEPENDIENTE'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(17, 'EN PÓLIZAS INDIVIDUALES.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(18, 'su póliza o de su renovación; no hacerlo conlleva la nulidad de la póliza a su fecha de emisión, sin necesidad de declaración judicial alguna, y por lo cual esta empresa de seguros no estará obligada'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(1, 'TIMBRES QUE CORRESPONDEN A ESTE DOCUMENTO SON PAGADOS POR DECLARACIÓN SEGÚN RESOLUCIÓN No. 213-4556 DEL 30 DE NOVIEMBRE DE 1993. Forman parte integral de esta'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(19, 'y/o modificaciones que de tiempo en tiempo se emitan por escrito.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(20, 'póliza: la solicitud suscrita por el Asegurado, estas Condiciones Particulares y las Condiciones Generales, las cuales el Asegurado acepta que ha leído y comprendido, así como los endosos'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(21, 'Esta póliza incluye las siguientes condiciones generales, endosos y anexos. Visite nuestra página web (www.asegurancon.com) para descargar las Condiciones Generales.'	);

INSERT INTO tmp_obs(secuencia,observacion)
VALUES(22, 'El Contratante declara que ha recibido una copia completa de la póliza a su entera satisfacción hoy, 21 de diciembre de 2012'	);

FOREACH	
	SELECT observacion
	  INTO v_observacion
	  FROM tmp_obs
	ORDER BY secuencia ASC

		  return v_observacion				 
		   WITH RESUME;
		   
end foreach;


END PROCEDURE	