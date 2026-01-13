"use client";

import { CSSProperties } from "react";
import styles from "./ImageSlider.module.css";

interface SliderStyle extends CSSProperties {
  "--quantity": string | number;
}

interface ItemStyle extends CSSProperties {
  "--position": string | number;
}

export const ImageSlider = () => {
  return (
    <div className={`${styles.banner}`}>
      <div className={styles.slider} style={{ "--quantity": 10 } as SliderStyle}>
        <div className={styles.item} style={{ "--position": 1 } as ItemStyle}>
          <img src="/nft-images/boat.jpg" alt="boat"></img>
        </div>
        <div className={styles.item} style={{ "--position": 2 } as ItemStyle}>
          <img src="/nft-images/bicycle.jpg" alt="bycicle"></img>
        </div>
        <div className={styles.item} style={{ "--position": 3 } as ItemStyle}>
          <img src="/nft-images/firetruck.jpg" alt="firetruck"></img>
        </div>
        <div className={styles.item} style={{ "--position": 4 } as ItemStyle}>
          <img src="/nft-images/hoverboard.jpg" alt="hoverboard"></img>
        </div>
        <div className={styles.item} style={{ "--position": 5 } as ItemStyle}>
          <img src="/nft-images/jetski.jpg" alt="jetski"></img>
        </div>
        <div className={styles.item} style={{ "--position": 6 } as ItemStyle}>
          <img src="/nft-images/motocross.jpg" alt="motocross"></img>
        </div>
        <div className={styles.item} style={{ "--position": 7 } as ItemStyle}>
          <img src="/nft-images/motorbike.jpg" alt="motorbike"></img>
        </div>
        <div className={styles.item} style={{ "--position": 8 } as ItemStyle}>
          <img src="/nft-images/policecar.jpg" alt="policecar"></img>
        </div>
        <div className={styles.item} style={{ "--position": 9 } as ItemStyle}>
          <img src="/nft-images/scooter.jpg" alt="scooter"></img>
        </div>
        <div className={styles.item} style={{ "--position": 10 } as ItemStyle}>
          <img src="/nft-images/segway.jpg" alt="segway"></img>
        </div>
        <div className={styles.item} style={{ "--position": 11 } as ItemStyle}>
          <img src="/nft-images/skateboard.jpg" alt="skateboard"></img>
        </div>
        <div className={styles.item} style={{ "--position": 12 } as ItemStyle}>
          <img src="/nft-images/train.jpg" alt="train"></img>
        </div>
        <div className={styles.item} style={{ "--position": 13 } as ItemStyle}>
          <img src="/nft-images/helicopter.jpg" alt="helicopter"></img>
        </div>
      </div>
    </div>
  );
};
