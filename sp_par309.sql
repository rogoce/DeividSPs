-- Procedimiento que Graba en parmailsend el corredor nuevo

-- Creado    : 25/10/2010 - Autor: Armando Moreno


--DROP PROCEDURE sp_par309;

CREATE PROCEDURE "informix".sp_par309(a_email CHAR(50), a_nombre varchar(50), 
a_cuenta    CHAR(25),
a_cod_aux	char(5), 
a_debito    DEC(16,2),
a_credito   DEC(16,2)
)

define _cantidad	smallint;


cod_tipo             char(5)
email                char(50)
enviado              smallint
adjunto              smallint
html_body            varchar(255)

let _cuerpo = "Estimado Usuario: " || trim(a_nombre)

INSERT INTO parmailsend(
cod_tipo, 
email,    
enviado,  
adjunto,  
html_body
)
VALUES(
'00001',
a_email,
0,
0,
_cuerpo
);


END PROCEDURE;
