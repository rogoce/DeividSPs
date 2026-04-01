--DROP trigger t_inserta_ponbitacora;
CREATE TRIGGER t_inserta_ponbitacora insert on "informix".ponderacion
REFERENCING NEW AS nuevo
	FOR EACH ROW(EXECUTE PROCEDURE sp_webp02() WITH TRIGGER REFERENCES);