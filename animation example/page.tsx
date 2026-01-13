"use client";

import styles from "./HomePage.module.css";
import type { NextPage } from "next";
import { CardsFan } from "~~/components/CardsFan";
import { ImageSlider } from "~~/components/ImageSlider";

const Home: NextPage = () => {
  return (
    <>
      <div className="flex flex-col items-center flex-grow z-10 pt-8">
        <div className="w-[100vw]">
          <h1 className={`${styles.title} text-center`}>
            <span className="block text-3xl sm:text-5xl mb-2 text-white shadow-inner">
              Get your pass to the future of
            </span>
            <span className="block text-5xl sm:text-7xl font-bold bg-clip-text text-transparent bg-gradient-to-b from-white via-slate-200 to-gray-600 drop-shadow-[0_10px_8px_rgba(0,0,0,0.8)] pb-2">
              sustainable mobility
            </span>
          </h1>

          <div>
            <ImageSlider />
          </div>
        </div>

        <div className="flex flex-col lg:flex-row w-full px-5 lg:px-20 my-5 h-[600px]">
          <div className={`${styles.description} opacity-0 flex flex-col w-full lg:w-1/2 pt-4`}>
            <h2>
              <span className="block text-3xl sm:text-5xl mb-2 text-white shadow-inner">Moove your way</span>
              <span className="block text-5xl sm:text-7xl font-bold bg-clip-text text-transparent bg-gradient-to-b from-white via-slate-200 to-gray-600 drop-shadow-[0_10px_8px_rgba(0,0,0,0.8)] pb-2">
                into the city
              </span>
            </h2>
            <p className="text-white text-lg mt-4">
              A mobility app that adapts to your day. Choose the best option for every moment and feel safe while going
              home.
            </p>
          </div>

          <div className="w-1/2 h-full">
            <img
              src="/3d-map/3d-map.jpg"
              alt="3D Map"
              className={`${styles.city} w-full h-full object-cover opacity-0`}
            />
          </div>
        </div>

        <div className="flex flex-col lg:flex-row-reverse w-full px-5 lg:px-20 my-40 h-[600px]">
          <div className={`${styles.description} opacity-0 flex flex-col w-full lg:w-1/2 pt-4`}>
            <h2 className="lg:ml-8">
              <span className="block text-3xl sm:text-5xl mb-2 text-white shadow-inner">Reduce the emissions,</span>
              <span className="block text-5xl sm:text-7xl font-bold bg-clip-text text-transparent bg-gradient-to-b from-white via-slate-200 to-gray-600 drop-shadow-[0_10px_8px_rgba(0,0,0,0.8)] pb-2">
                help the planet
              </span>
            </h2>
            <p className="text-white text-lg mt-4 lg:ml-8">
              Moove vehicles are 100% electric. Share your journey with a friend and you will be rewarded with a fee
              discount on your next ride.
            </p>
          </div>

          <div className="w-full lg:w-1/2 h-full">
            <img
              src="/green-forest/green-forest.jpg"
              alt="Green Forest"
              className={`${styles.forest} w-full h-full object-cover opacity-0`}
            />
          </div>
        </div>

        <div className="flex flex-col items-center w-full px-5 lg:px-20 mb-40 h-[600px]">
          <div className={`${styles.description} opacity-0 flex flex-col items-center w-full lg:w-[70%] pt-4`}>
            <h2>
              <span className="block text-3xl sm:text-5xl mb-2 text-white shadow-inner text-center">Introducing</span>
              <span className="block text-5xl sm:text-7xl text-center font-bold bg-clip-text text-transparent bg-gradient-to-b from-white via-slate-200 to-gray-600 drop-shadow-[0_10px_8px_rgba(0,0,0,0.8)] pb-2">
                Moove NFTs
              </span>
            </h2>
            <p className="text-white text-center text-lg mt-4 w-full lg:w-[80%]">
              Participate in public auctions and obtain your first Moove NFT. Get privileged access to vehicles and
              discounts on community events.
            </p>
          </div>

          <div className="w-1/2 h-full">
            <CardsFan />
          </div>
        </div>

        <div className="flex flex-col w-full px-5 lg:px-20 my-0 md:my-40 mb-40 h-[600px] items-center">
          <div className={`${styles.description} opacity-0 flex flex-col w-full pt-4`}>
            <h2>
              <span className="block text-3xl sm:text-5xl mb-2 text-center text-white shadow-inner">
                Be part of the change,
              </span>
              <span className="block text-5xl sm:text-7xl text-center font-bold bg-clip-text text-transparent bg-gradient-to-b from-white via-slate-200 to-gray-600 drop-shadow-[0_10px_8px_rgba(0,0,0,0.8)] pb-2">
                join the community
              </span>
            </h2>
            <p className="text-white text-lg text-center mt-4">
              Meet other Moovers in our Discord, plan your trip and split the costs.
            </p>
          </div>

          <div className="flex space-x-10 items-center">
            <div className="flex flex-col items-center">
              <img src="/discord.jpg" alt="Discord" className={`${styles.icons} opacity-0`} />
              <div className="flex items-center justify-center mt-2 space-x-2">
                <button className={`${styles.buttons} btn btn-primary btn-sm mt-1`}>Open Discord</button>
              </div>
            </div>
            <div className="flex flex-col items-center">
              <img src="/moove-app.png" alt="Discord" className={`${styles.icons} opacity-0`} />
              <div className="flex items-center justify-center mt-2 space-x-2">
                <button className={`${styles.buttons} btn btn-primary btn-sm mt-1`}>Download the app</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
